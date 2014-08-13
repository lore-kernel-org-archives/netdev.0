From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit immediate"
 eBPF instruction
Date: Wed, 13 Aug 2014 14:16:35 -0700
Message-ID: <53EBD5B3.10200@zytor.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>	<1407916658-8731-2-git-send-email-ast@plumgrid.com>	<CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>	<CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>	<CALCETrXfp+7FmEzAoLiqzqY73NBzt8JsD40hzvhT3=gr-Scp=g@mail.gmail.com> <CAMEtUuwx6Y4qxyz4TGK9=M2BH-dXnPsm+JrusqbyjzK20yUv6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuwx6Y4qxyz4TGK9=M2BH-dXnPsm+JrusqbyjzK20yUv6A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/13/2014 02:02 PM, Alexei Starovoitov wrote:
> On Wed, Aug 13, 2014 at 11:35 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>
>> The compiler can still think of it as a single insn, though, but some
>> future compiler might not.
> 
> I think that would be very dangerous.
> compiler (user space) and kernel interpreter must have the same
> understanding of ISA.
> 

Only at the point of the interface layer.  The compiler can treat it as
a single instruction internally, the JIT can do peephole optimization,
but as long as the instruction stream at the boundary matches the
official ISA spec everything is fine.

	-hpa
