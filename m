From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/3] BPF updates
Date: Wed, 30 Sep 2015 01:41:49 +0200
Message-ID: <cover.1443567433.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59693 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbI2Xl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:41:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor updates to {cls,act}_bpf to retrieve routing realms
and to make skb->priority writable.

Thanks!

v1 -> v2:
 - Dropped preclassify patch for now from the series as the
   rest is pretty much independent of it
 - Rest unchanged, only rebased and already posted Acked-by's kept

Daniel Borkmann (3):
  ebpf: migrate bpf_prog's flags to bitfield
  sched, bpf: add helper for retrieving routing realms
  sched, bpf: make skb->priority writable

 arch/arm/net/bpf_jit_32.c       |  2 +-
 arch/arm64/net/bpf_jit_comp.c   |  2 +-
 arch/mips/net/bpf_jit.c         |  2 +-
 arch/powerpc/net/bpf_jit_comp.c |  2 +-
 arch/s390/net/bpf_jit_comp.c    |  2 +-
 arch/sparc/net/bpf_jit_comp.c   |  2 +-
 arch/x86/net/bpf_jit_comp.c     |  2 +-
 include/linux/filter.h          |  7 +++++--
 include/uapi/linux/bpf.h        |  7 +++++++
 kernel/bpf/core.c               |  4 ++++
 kernel/bpf/syscall.c            |  6 ++++--
 net/core/filter.c               | 33 ++++++++++++++++++++++++++++++---
 net/sched/cls_bpf.c             |  8 ++++++--
 13 files changed, 63 insertions(+), 16 deletions(-)

-- 
1.9.3
