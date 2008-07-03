From: David Miller <davem@davemloft.net>
Subject: [PATCH 38/39]: netdev: Kill plain netif_schedule()
Date: Thu, 03 Jul 2008 00:05:53 -0700 (PDT)
Message-ID: <20080703.000553.36472751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50762
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759542AbYGCHFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:05:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No more users.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8b83d1f..74f4cdc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -978,11 +978,6 @@ static inline void netif_schedule_queue(struct netdev_queue *dev_queue)
 		__netif_schedule(dev_queue);
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
1.5.6

