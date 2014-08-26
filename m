From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v6 net-next 4/6] bpf: enable bpf syscall on x64 and i386
Date: Tue, 26 Aug 2014 10:02:31 +0200
Message-ID: <20140826080231.GA20565@gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
 <1409014858-1410-5-git-send-email-ast@plumgrid.com>
 <20140825205201.10ac5ee3@uryu.home.lan>
 <CAMEtUuxicvHsEQ59CeG2kmLW0b4TQ9ExfDkKo2kktH-t8x5tBg@mail.gmail.com>
 <20140826074655.GB19799@gmail.com>
 <53FC3E9A.1020108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53FC3E9A.1020108-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On 08/26/2014 09:46 AM, Ingo Molnar wrote:
> >* Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> >>On Mon, Aug 25, 2014 at 8:52 PM, Stephen Hemminger
> >><stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org> wrote:
> >>>Per discussion at Kernel Summit. Every new syscall requires
> >>>a manual page and test programs. We have had too many new syscalls
> >>>that are DOA.
> >>
> >>There is verifier testsuite that is testing eBPF verifier from userspace
> >>via bpf syscall. Also there are multiple examples and libbpf.
> >>I think test coverage for bpf syscall is quite substantial already.
> >
> >This is in tools/bpf/, right?
> 
> No, it contains a BPF JIT disasm, bpf assembler and a debugger, 
> but the last two are for the 'classic' BPF interface only. 
> There's a test suite for BPF/eBPF in general under 
> lib/test_bpf.c, but so far it tests only the current code w/o 
> eBPF verifier.
> 
> That said, I think Alexei is referring to the examples et al 
> from the bigger previous proposed patch set.

I mean, if all the testing already exists, it should be part of 
an initial submission and such.

Thanks,

	Ingo
