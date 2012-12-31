From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/8] Add complementary BPF conditional jump instructions
Date: Mon, 31 Dec 2012 14:59:40 +0100
Message-ID: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156Ab2LaN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 08:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds adds jump operations for lt (<), le (<=), ne (!=) that
compare A with K resp. X in order to facilitate filter programming
with conditional jumps, as also available in McCanne et. al's BPF+
paper (``BPF+: Exploiting Global Data-flow Optimization in a Generalized
Packet Filter Architecture'').

Also, follow-up BPF JIT implementations for x86, Sparc and PowerPC
are added in this set.

Daniel Borkmann (8):
  net: bpf: add lt,le jump operations to bpf machine
  x86: bpf_jit_comp: add JMP instructions for BPF JIT
  sparc: bpf_jit_comp: add JMP instructions for BPF JIT
  PPC: bpf_jit_comp: add JMP instructions for BPF JIT
  net: bpf: add neq jump operations to bpf machine
  x86: bpf_jit_comp: add JMP_NEQ instructions for BPF JIT
  sparc: bpf_jit_comp: add JMP_NEQ instructions for BPF JIT
  PPC: bpf_jit_comp: add JMP_NEQ instructions for BPF JIT

 arch/powerpc/net/bpf_jit.h      |  1 +
 arch/powerpc/net/bpf_jit_comp.c | 16 ++++++++++++++++
 arch/sparc/net/bpf_jit_comp.c   | 12 ++++++++++++
 arch/x86/net/bpf_jit_comp.c     | 12 ++++++++++++
 include/linux/filter.h          |  6 ++++++
 include/uapi/linux/filter.h     |  4 ++++
 net/core/filter.c               | 42 +++++++++++++++++++++++++++++++++++++++++
 7 files changed, 93 insertions(+)

-- 
1.7.11.7
