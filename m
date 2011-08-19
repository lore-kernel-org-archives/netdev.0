From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: add the comment for skb->l4_hash
Date: Fri, 19 Aug 2011 22:14:12 +0800
Message-ID: <1313763252-3235-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f170.google.com ([209.85.210.170]:38272 "EHLO
	mail-iy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685Ab1HSOPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:15:06 -0400
Received: by iye16 with SMTP id 16so5656737iye.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:15:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/skbuff.h |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f902c33..10109a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -322,6 +322,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
+ *	@l4_hash: indicate rxhash is a canonical 4-tuple hash over transport
+ *		ports.
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
