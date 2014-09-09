From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v10 net-next 0/2] load imm64 insn and uapi/linux/bpf.h
Date: Tue, 09 Sep 2014 10:30:59 -0700 (PDT)
Message-ID: <20140909.103059.1330265085939107782.davem@davemloft.net>
References: <1409894238-9055-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409894238-9055-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Thu,  4 Sep 2014 22:17:16 -0700

> V9->V10
> - no changes, added Daniel's ack
> 
> Note they're on top of Hannes's patch in the same area [1]
> 
> V8 thread with 'why' reasoning and end goal [2]
> 
> Original set [3] of ~28 patches I'm planning to present in 4 stages:
> 
>   I. this 2 patches to fork off llvm upstreaming
>  II. bpf syscall with manpage and map implementation
> III. bpf program load/unload with verifier testsuite (1st user of
>      instruction macros from bpf.h and 1st user of load imm64 insn)
>  IV. tracing, etc
> 
> [1] http://patchwork.ozlabs.org/patch/385266/
> [2] https://lkml.org/lkml/2014/8/27/628
> [3] https://lkml.org/lkml/2014/8/26/859

Begrudgingly, I've applied this series.

Although I really wish you had included the mechanism for userland to
use the eBPF instructions alongside exporting them to userspace.

You kept saying "LLVM is the user" but that's a bullshit argument
because you aren't including the patches necessary to actually
propagate native eBPF programs into the kernel.

That's what, 1 or 2 patches, right?  Which is not an unreasonable
request.

Anyways, I'm just extremely frustrated with how you operate and work,
you push things way too hard.  I hate to say this, but you are the
kind of submitter who gets his way by being persistent rather than
making well formed pleasant submissions that are easy to integrate.
