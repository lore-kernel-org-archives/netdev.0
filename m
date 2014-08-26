From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v6 net-next 4/6] bpf: enable bpf syscall on x64 and i386
Date: Tue, 26 Aug 2014 09:40:18 -0700
Message-ID: <CAMEtUuyBqTuqdhpmgYHJm2A-sLmmf5JzRaNG-qxTkDiJgMBNVg@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-5-git-send-email-ast@plumgrid.com>
	<20140825205201.10ac5ee3@uryu.home.lan>
	<CAMEtUuxicvHsEQ59CeG2kmLW0b4TQ9ExfDkKo2kktH-t8x5tBg@mail.gmail.com>
	<20140826074655.GB19799@gmail.com>
	<53FC3E9A.1020108@redhat.com>
	<20140826080231.GA20565@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
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
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140826080231.GA20565-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2014 at 1:02 AM, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
>> That said, I think Alexei is referring to the examples et al
>> from the bigger previous proposed patch set.
>
> I mean, if all the testing already exists, it should be part of
> an initial submission and such.

That's what I did. V5 set contains all examples and verifier testsuite:
https://lkml.org/lkml/2014/8/24/107
Dave asked to split it up into subsets, since it's too big too review
at once. which makes sense, so this V6 is only first part and
the plan was:
1st(this) set - introduces uapi/linux/bpf.h and BPF syscall for maps only
2nd set will extend BPF syscall with programs and verifier
3rd set will use eBPF in tracing, add samples and verifier tests
4th set will have llvm and C examples
Each set is around 6-8 patches instead of 29 in V5
