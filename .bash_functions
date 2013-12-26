#!/bin/bash
#
__git_ps1 ()
{
  local g="$(__gitdir)";
  if [ -n "$g" ]; then
    local r="";
    local b="";
    if [ -f "$g/rebase-merge/interactive" ]; then
      r="|REBASE-i";
      b="$(cat "$g/rebase-merge/head-name")";
    else
      if [ -d "$g/rebase-merge" ]; then
        r="|REBASE-m";
        b="$(cat "$g/rebase-merge/head-name")";
      else
        if [ -d "$g/rebase-apply" ]; then
          if [ -f "$g/rebase-apply/rebasing" ]; then
            r="|REBASE";
          else
            if [ -f "$g/rebase-apply/applying" ]; then
              r="|AM";
            else
              r="|AM/REBASE";
            fi;
          fi;
        else
          if [ -f "$g/MERGE_HEAD" ]; then
            r="|MERGING";
          else
            if [ -f "$g/BISECT_LOG" ]; then
              r="|BISECTING";
            fi;
          fi;
        fi;
        b="$(git symbolic-ref HEAD 2>/dev/null)" || {
          b="$(
        case "${GIT_PS1_DESCRIBE_STYLE-}" in
          (contains)
            git describe --contains HEAD ;;
          (branch)
            git describe --contains --all HEAD ;;
          (describe)
            git describe HEAD ;;
          (* | default)
            git describe --tags --exact-match HEAD ;;
        esac 2>/dev/null)" || b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || b="unknown";
          b="($b)"
        };
      fi;
    fi;
    local w="";
    local i="";
    local s="";
    local u="";
    local c="";
    local p="";
    if [ "true" = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
      if [ "true" = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
        c="BARE:";
      else
        b="GIT_DIR!";
      fi;
    else
      if [ "true" = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
        if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ]; then
          if [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
            git diff --no-ext-diff --quiet --exit-code || w="*";
            if git rev-parse --quiet --verify HEAD > /dev/null; then
              git diff-index --cached --quiet HEAD -- || i="+";
            else
              i="#";
            fi;
          fi;
        fi;
        if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ]; then
          git rev-parse --verify refs/stash > /dev/null 2>&1 && s="$";
        fi;
        if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ]; then
          if [ -n "$(git ls-files --others --exclude-standard)" ]; then
            u="%";
          fi;
        fi;
        if [ -n "${GIT_PS1_SHOWUPSTREAM-}" ]; then
          __git_ps1_show_upstream;
        fi;
      fi;
    fi;
    local f="$w$i$s$u";
    printf "${1:- (%s)}" "$c${b##refs/heads/}${f:+ $f}$r$p";
  fi
}

__gitdir ()
{
  if [ -z "${1-}" ]; then
    if [ -n "${__git_dir-}" ]; then
      echo "$__git_dir";
    else
      if [ -d .git ]; then
        echo .git;
      else
        git rev-parse --git-dir 2> /dev/null;
      fi;
    fi;
  else
    if [ -d "$1/.git" ]; then
      echo "$1/.git";
    else
      echo "$1";
    fi;
  fi
}


parse_git ()
{
  # output=$(__git_ps1 "[%s]")
  output=$(__git_ps1 "‹%s›")
  if [ $output ]; then
    echo "$output "
  fi
}

function_exists ()
{
  type -t $1
}

is_root ()
{
  if [ $UID == 0 ]; then
    echo "(root)"
  fi
}

echored ()
{
  echo -e "\033[1;31m$@\033[0m"
}

echogreen ()
{
  echo -e "\033[1;32m$@\033[0m"
}

echoyellow ()
{
  echo -e "\033[1;33m$@\033[0m"
}

printfred ()
{
  printf "\033[1;31m$1\033[0m\n"
}

printfgreen ()
{
  printf "\033[1;32m$1\033[0m\n"
}

printfyellow ()
{
  printf "\033[1;33m$1\033[0m\n"
}

__ruby_version ()
{
  ruby=$(command -v ruby)
  if [[ -n "$ruby" ]]; then
    if [[ $(echo $ruby | grep -o "rvm") == "rvm" ]]; then
      version="$(ruby --version)"
      ver=$(echo $version | awk '{print $2}')
      impl=$(echo $version | awk '{print $1}')
      if [[ $impl != "ruby" ]]; then
        version="‹rvm ${impl} ${ver}›"
      else
        version="‹rvm ${ver}›"
      fi
    else
      # version="(system)"
      version="‹system›"
    fi
    echo "$version "
  fi
}

__rbenv_ps1 () {
  rbenv_ruby_version="$(rbenv version 2>/dev/null| sed -e 's; .*; ;g')"
  printf "$rbenv_ruby_version"
}

__parse_git () {
  output=$(__git_ps1)
  if [[ -n "$output" ]]; then
    output=$(echo $output | sed "s;^\s*;;g;s;\s*$;;g")" "
  else
    output=""
  fi
  echo "$output"
}

__python_version ()
{
  python=$(command -v python)
  if [[ -n "$python" ]]; then
    if [[ $(echo $python | grep -o "brew") == "brew" ]]; then
      version="(pybrew $(python --version 2>&1 | awk '{print $2}'))"
    else
      version="(system)"
    fi
    echo "$version"
  fi
}
