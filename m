From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 0/3] Few BPF helper related checksum fixes
Date: Fri,  5 Aug 2016 00:11:10 +0200
Message-ID: <cover.1470346863.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38666 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965241AbcHDWLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 18:11:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set contains three fixes with regards to CHECKSUM_COMPLETE
and BPF helper functions. For details please see individual
patches.

Thanks!

v1 -> v2:
  - Fixed make htmldocs issue reported by kbuild bot.
  - Rest as is.

Daniel Borkmann (3):
  bpf: also call skb_postpush_rcsum on xmit occasions
  bpf: fix checksum fixups on bpf_skb_store_bytes
  bpf: fix checksum for vlan push/pop helper

 include/linux/skbuff.h | 52 ++++++++++++++++++++++++++++++++------------------
 net/core/filter.c      | 29 +++++++++++++++++++++++-----
 2 files changed, 57 insertions(+), 24 deletions(-)

-- 
1.9.3
