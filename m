From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH v3 4/5] kcmp: add KCMP_FILE_PRIVATE_DATA
Date: Wed, 30 Sep 2015 11:25:41 -0700
Message-ID: <CALCETrUosV+ND1BC-qH3xZMaLwnex50SvMhaSa3FQ19oy1MBVg@mail.gmail.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com> <1443636820-17083-5-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443636820-17083-5-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
<tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> This command allows comparing the underling private data of two fds. This
> is useful e.g. to find out if a seccomp filter is inherited, since struct
> seccomp_filter are unique across tasks and are the private_data seccomp
> fds.

This is very implementation-specific and may have nasty ABI
consequences far outside seccomp.  Let's do something specific to
seccomp and/or eBPF.

--Andy
