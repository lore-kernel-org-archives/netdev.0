From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v9 net-next 0/4] load imm64 insn and uapi/linux/bpf.h
Date: Tue,  2 Sep 2014 20:17:22 -0700
Message-ID: <1409714246-31054-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

V8->V9
- rebase on top of Hannes's patch in the same area [1]
- no changes to patches 1 and 2
- added patches 3 and 4 as RFC to address Daniel's concern.
  patch 3 moves eBPF instruction macros and
  patch 4 split macros which are shared between classic and eBPF
  into bpf_common.h
  3 and 4 will be used by verifier testsuite and will be reposted later
  during stage III

V8 thread with 'why' reasoning and end goal:
https://lkml.org/lkml/2014/8/27/628

Original set [2] of ~28 patches I'm planning to present in 4 stages:

  I. this 2 patches to fork off llvm upstreaming
 II. bpf syscall with manpage and map implementation
III. bpf program load/unload with verifier testsuite (1st user of
     instruction macros from bpf.h and 1st user of load imm64 insn)
 IV. tracing, etc

[1] http://patchwork.ozlabs.org/patch/385266/
[2] https://lkml.org/lkml/2014/8/26/859
