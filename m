From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] Minor BPF updates
Date: Thu, 30 Jul 2015 12:42:45 +0200
Message-ID: <cover.1438250937.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, holzheu@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52551 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbbG3Kmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 06:42:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various minor misc updates.

Thanks!

Daniel Borkmann (4):
  test_bpf: assign type to native eBPF test cases
  bpf: provide helper that indicates eBPF was migrated
  bpf, x86/sparc: show actual number of passes in bpf_jit_dump
  bpf: also show process name/pid in bpf_jit_dump

 arch/s390/net/bpf_jit_comp.c  |  2 +-
 arch/sparc/net/bpf_jit_comp.c |  2 +-
 arch/x86/net/bpf_jit_comp.c   |  2 +-
 include/linux/filter.h        | 16 ++++++++++++++--
 lib/test_bpf.c                |  2 ++
 5 files changed, 19 insertions(+), 5 deletions(-)

-- 
1.9.3
