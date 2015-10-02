From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: v5 of seccomp filter c/r patches
Date: Fri,  2 Oct 2015 10:27:20 -0600
Message-ID: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here's v5 of the seccomp filter c/r set. The individual patch notes have
changes, but two highlights are:

* This series is now based on http://patchwork.ozlabs.org/patch/525492/ and
  will need to be built with that patch applied. This gets rid of two incorrect
  patches in the previous series and is a nicer API.

* I couldn't figure out a nice way to have SECCOMP_GET_FILTER_FD return the
  same struct file across calls, so we still need a kcmp command. I've narrowed
  the scope of the one being added to only compare seccomp fds.

Thoughts welcome,

Tycho
