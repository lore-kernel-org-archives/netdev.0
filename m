From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/15]: netdevice.h: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:01:53 -0700 (PDT)
Message-ID: <20090609.050153.106519081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756919AbZFIMBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:01:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DAEE5C8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:01:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2a80138..9ea8d6d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1904,7 +1904,7 @@ static inline int net_gso_ok(int features, int gso_type)
 static inline int skb_gso_ok(struct sk_buff *skb, int features)
 {
 	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
-	       (!skb_shinfo(skb)->frag_list || (features & NETIF_F_FRAGLIST));
+	       (!skb_has_frags(skb) || (features & NETIF_F_FRAGLIST));
 }
 
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
-- 
1.6.3.2

