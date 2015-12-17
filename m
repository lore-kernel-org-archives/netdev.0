From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/5] Misc BPF updates
Date: Thu, 17 Dec 2015 23:51:52 +0100
Message-ID: <cover.1450391511.git.daniel@iogearbox.net>
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53876 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbbLQWwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:52:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains a couple of misc updates to the BPF code, besides
others a new helper bpf_skb_load_bytes(), moving clearing of A/X to the
classic converter, etc. Please see individual patches for details.

Thanks!

Daniel Borkmann (5):
  bpf: add bpf_skb_load_bytes helper
  bpf: move clearing of A/X into classic to eBPF migration prologue
  bpf: fix misleading comment in bpf_convert_filter
  bpf, x86: detect/optimize loading 0 immediates
  bpf, test: add couple of test cases

 arch/arm64/net/bpf_jit_comp.c |   6 ---
 arch/s390/net/bpf_jit_comp.c  |  13 +----
 arch/x86/net/bpf_jit_comp.c   |  40 ++++++++++++--
 include/uapi/linux/bpf.h      |   1 +
 kernel/bpf/core.c             |   4 --
 lib/test_bpf.c                | 120 ++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c             |  60 +++++++++++++++++----
 7 files changed, 208 insertions(+), 36 deletions(-)

-- 
1.9.3
