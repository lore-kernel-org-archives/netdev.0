From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/2] eBPF updates
Date: Sat, 14 Mar 2015 02:27:15 +0100
Message-ID: <cover.1426294922.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56322 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbCNB1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 21:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two small eBPF helper additions to better match up with ancillary
classic BPF functionality.

Daniel Borkmann (2):
  ebpf: add prandom helper for packet sampling
  ebpf: add helper for obtaining current processor id

 include/linux/bpf.h      |  3 +++
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/core.c        |  3 +++
 kernel/bpf/helpers.c     | 24 ++++++++++++++++++++++++
 net/core/filter.c        |  4 ++++
 5 files changed, 36 insertions(+)

-- 
1.9.3
