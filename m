From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/3] BPF updates
Date: Mon,  8 Sep 2014 08:04:46 +0200
Message-ID: <1410156289-3190-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, mgherzan@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685AbaIHGEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 02:04:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Set applies on top of current net-next but also on top of
  Alexei's latest patches. Please see individual patches for
  more details. ]

Changelog:
 v1->v2:
  - Removed paragraph in 1st commit message
  - Rest stays the same

Daniel Borkmann (3):
  net: bpf: consolidate JIT binary allocator
  net: bpf: arm: address randomize and write protect JIT code
  net: bpf: be friendly to kmemcheck

 arch/arm/net/bpf_jit_32.c       | 34 +++++++++++++++++++++------
 arch/mips/net/bpf_jit.c         |  2 +-
 arch/powerpc/net/bpf_jit_comp.c |  2 +-
 arch/s390/net/bpf_jit_comp.c    | 47 ++++++++-----------------------------
 arch/sparc/net/bpf_jit_comp.c   |  2 +-
 arch/x86/net/bpf_jit_comp.c     | 52 ++++++++++-------------------------------
 include/linux/filter.h          | 19 ++++++++++++---
 kernel/bpf/core.c               | 39 +++++++++++++++++++++++++++++++
 net/core/filter.c               |  2 +-
 9 files changed, 108 insertions(+), 91 deletions(-)

-- 
1.7.11.7
