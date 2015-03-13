From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] eBPF updates
Date: Fri, 13 Mar 2015 14:22:02 +0100
Message-ID: <cover.1426249641.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59359 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbCMNWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:22:10 -0400
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
 kernel/bpf/helpers.c     | 25 +++++++++++++++++++++++++
 net/core/filter.c        |  4 ++++
 5 files changed, 37 insertions(+)

-- 
1.9.3
