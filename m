From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] BPF updates
Date: Tue,  1 Sep 2015 18:34:21 +0200
Message-ID: <cover.1441123709.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49531 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbbIAQea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:34:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a couple of improvements to bpf classifier and actions
as well as mqprio. Please see individual patches for details. The series
was still in my queue, I realize it's rather late, so I also don't have
any problem deferring this for the next net-next cycle if it's preferred.

Thanks (also to Alexei for his reviews)!

Daniel Borkmann (3):
  ebpf: migrate bpf_prog's flags to bitfield
  net: {cls,act}_bpf: add helper for retrieving routing realms
  net: {cls,act}_bpf: make skb->priority writable

John Fastabend (1):
  net: qdisc: add op to run filters/actions before enqueue

 arch/arm/net/bpf_jit_32.c       |  2 +-
 arch/arm64/net/bpf_jit_comp.c   |  2 +-
 arch/mips/net/bpf_jit.c         |  2 +-
 arch/powerpc/net/bpf_jit_comp.c |  2 +-
 arch/s390/net/bpf_jit_comp.c    |  2 +-
 arch/sparc/net/bpf_jit_comp.c   |  2 +-
 arch/x86/net/bpf_jit_comp.c     |  2 +-
 include/linux/filter.h          |  7 +++++--
 include/net/sch_generic.h       | 16 +++++++++++-----
 include/uapi/linux/bpf.h        |  7 +++++++
 kernel/bpf/core.c               |  4 ++++
 kernel/bpf/syscall.c            |  6 ++++--
 net/core/dev.c                  | 17 +++++++++++++++++
 net/core/filter.c               | 33 ++++++++++++++++++++++++++++++---
 net/sched/Kconfig               |  5 +++++
 net/sched/cls_bpf.c             |  9 ++++++---
 net/sched/sch_generic.c         |  1 +
 net/sched/sch_mqprio.c          | 35 +++++++++++++++++++++++++++++++++++
 18 files changed, 132 insertions(+), 22 deletions(-)

-- 
1.9.3
