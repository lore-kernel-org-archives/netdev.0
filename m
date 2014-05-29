From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/4] BPF + test suite updates
Date: Thu, 29 May 2014 10:22:47 +0200
Message-ID: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932373AbaE2IW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 04:22:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are the last bigger BPF changes that I had in my todo
queue for now. As the first two patches from this series
contain additional test cases for the test suite, I have
rebased them on top of current net-next with the set from [1]
applied to avoid introducing any unnecessary merge conflicts.

For details, please refer to the individual patches. Test
suite runs fine with the set applied.

Thanks a lot,

Daniel

 [1] http://patchwork.ozlabs.org/patch/352599/
     http://patchwork.ozlabs.org/patch/352600/

Daniel Borkmann (4):
  net: filter: add slot overlapping test with fully filled M[]
  net: filter: add test for loading SKF_AD_OFF limits
  net: filter: get rid of BPF_S_* enum
  net: filter: explicit initialization in filter block macros

 arch/arm/net/bpf_jit_32.c       | 139 +++++------
 arch/powerpc/net/bpf_jit_64.S   |   2 +-
 arch/powerpc/net/bpf_jit_comp.c | 157 ++++++------
 arch/s390/net/bpf_jit_comp.c    | 163 ++++++------
 arch/sparc/net/bpf_jit_comp.c   | 154 ++++++------
 include/linux/filter.h          | 363 ++++++++++++++++++---------
 kernel/seccomp.c                |  83 +++----
 lib/test_bpf.c                  |  97 +++++++-
 net/core/filter.c               | 537 +++++++++++++++-------------------------
 9 files changed, 871 insertions(+), 824 deletions(-)

-- 
1.7.11.7
