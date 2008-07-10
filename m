From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/13]: netdev: Kill struct net_device_subqueue and
 netdev->egress_subqueue*
Date: Thu, 10 Jul 2008 03:56:51 -0700 (PDT)
Message-ID: <20080710.035651.111849209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754045AbYGJK4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:56:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 313FEC8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:56:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0d69931..661fe81 100644
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
@@ -760,10 +752,6 @@ struct net_device
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

