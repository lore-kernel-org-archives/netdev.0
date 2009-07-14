From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH] skbuff.h: Fix comment for NET_IP_ALIGN
Date: Tue, 14 Jul 2009 10:48:16 +0200
Message-ID: <1247561296-25010-1-git-send-email-klto@zhaw.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <klto@zhaw.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:49562 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbZGNIsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 04:48:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the correct function call for skb_reserve in the comment for
NET_IP_ALIGN.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 include/linux/skbuff.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b47b3f0..f2c69a2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1342,12 +1342,12 @@ static inline int skb_network_offset(const struct sk_buff *skb)
  * shifting the start of the packet by 2 bytes. Drivers should do this
  * with:
  *
- * skb_reserve(NET_IP_ALIGN);
+ * skb_reserve(skb, NET_IP_ALIGN);
  *
  * The downside to this alignment of the IP header is that the DMA is now
  * unaligned. On some architectures the cost of an unaligned DMA is high
  * and this cost outweighs the gains made by aligning the IP header.
- * 
+ *
  * Since this trade off varies between architectures, we allow NET_IP_ALIGN
  * to be overridden.
  */
-- 
1.6.0.4

