From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/31]: netdev: Kill plain netif_schedule()
Date: Thu, 17 Jul 2008 05:16:46 -0700 (PDT)
Message-ID: <20080717.051646.105526638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758930AbYGQMQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:16:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No more users.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9464e64..787fbfc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -994,11 +994,6 @@ static inline void netif_schedule_queue(struct netdev_queue *txq)
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

