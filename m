From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/13]: netdev: Kill plain netif_schedule()
Date: Thu, 10 Jul 2008 03:57:25 -0700 (PDT)
Message-ID: <20080710.035725.23873689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754607AbYGJK5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:57:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3A27AC8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:57:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No more users.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 17a81d0..aae711f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -980,11 +980,6 @@ static inline void netif_schedule_queue(struct netdev_queue *txq)
 		__netif_schedule(txq);
 }
 
-static inline void netif_schedule(struct net_device *dev)
-{
-	netif_schedule_queue(netdev_get_tx_queue(dev, 0));
-}
-
 static inline void netif_tx_schedule_all(struct net_device *dev)
 {
 	unsigned int i;
-- 
1.5.6.2.255.gbed62

