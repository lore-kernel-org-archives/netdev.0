From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/31]: netdev: Kill struct net_device_subqueue and
 netdev->egress_subqueue*
Date: Thu, 17 Jul 2008 05:16:14 -0700 (PDT)
Message-ID: <20080717.051614.53304618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757402AbYGQMQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:16:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b5c1e7d..a1c2c22 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -118,14 +118,6 @@ struct wireless_dev;
 
 #endif  /*  __KERNEL__  */
 
-struct net_device_subqueue
-{
-	/* Give a control state for each queue.  This struct may contain
-	 * per-queue locks in the future.
-	 */
-	unsigned long   state;
-};
-
 /*
  *	Network device statistics. Akin to the 2.0 ether stats but
  *	with byte counters.
@@ -761,10 +753,6 @@ struct net_device
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
-
-	/* The TX queue control structures */
-	unsigned int			egress_subqueue_count;
-	struct net_device_subqueue	egress_subqueue[1];
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
-- 
1.5.6.2.255.gbed62

