From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] Few BPF helper related checksum fixes
Date: Thu,  4 Aug 2016 02:50:07 +0200
Message-ID: <cover.1470270323.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48979 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933214AbcHDAu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 20:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set contains three fixes with regards to CHECKSUM_COMPLETE
and BPF helper functions. For details please see individual
patches.

Thanks!

Daniel Borkmann (3):
  bpf: also call skb_postpush_rcsum on xmit occasions
  bpf: fix checksum fixups on bpf_skb_store_bytes
  bpf: fix checksum for vlan push/pop helper

 include/linux/skbuff.h | 38 ++++++++++++++++++++++----------------
 net/core/filter.c      | 29 ++++++++++++++++++++++++-----
 2 files changed, 46 insertions(+), 21 deletions(-)

-- 
1.9.3
