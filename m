From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: v5 of seccomp filter c/r patches
Date: Fri, 2 Oct 2015 16:59:15 -0600
Message-ID: <20151002225915.GP23065@smitten>
References: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJJoM3NdwSmigWy8trTBATsvkGUDmbZ02QOyU=1tD0Y-w@mail.gmail.com>
 <20151002224443.GN23065@smitten>
 <560F0BED.2070304@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <560F0BED.2070304-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 03, 2015 at 12:57:49AM +0200, Daniel Borkmann wrote:
> On 10/03/2015 12:44 AM, Tycho Andersen wrote:
> >On Fri, Oct 02, 2015 at 02:10:24PM -0700, Kees Cook wrote:
> ...
> >Ok, how about,
> >
> >struct sock_filter insns[BPF_MAXINSNS];
> >insn_cnt = ptrace(PTRACE_SECCOMP_GET_FILTER, pid, insns, i);
> 
> Would also be good that when the storage buffer (insns) is NULL,
> it just returns you the number of sock_filter insns (or 0 when
> nothing attached).
> 
> That would be consistent with classic socket filters (see
> sk_get_filter()), and user space could allocate a specific
> size instead of always passing in max insns.

Yep, the current set does this with SECCOMP_FD_DUMP and I agree that
it's nice behavior, so I'll plan on preserving it.

Thanks,

Tycho
