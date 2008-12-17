From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-next] vcan: whitepace fixes
Date: Wed, 17 Dec 2008 10:40:14 +0100
Message-ID: <4948C8FE.3010506@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040605030902040505030105"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:37619 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759965AbYLQJkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 04:40:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040605030902040505030105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

vcan: whitespace fixes

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
---

Hello Dave,

when adding the net_device_ops support to the vcan driver i discovered several 
whitepace issues in the driver setup section. This patch fixes them.

Thanks,
Oliver




--------------040605030902040505030105
Content-Type: text/x-patch;
 name="vcan_whitespace_fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vcan_whitespace_fixes.patch"

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index f127ec9..a10c1d7 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -134,24 +134,24 @@ static const struct net_device_ops vcan_netdev_ops = {
 
 static void vcan_setup(struct net_device *dev)
 {
-	dev->type              = ARPHRD_CAN;
-	dev->mtu               = sizeof(struct can_frame);
-	dev->hard_header_len   = 0;
-	dev->addr_len          = 0;
-	dev->tx_queue_len      = 0;
-	dev->flags             = IFF_NOARP;
+	dev->type		= ARPHRD_CAN;
+	dev->mtu		= sizeof(struct can_frame);
+	dev->hard_header_len	= 0;
+	dev->addr_len		= 0;
+	dev->tx_queue_len	= 0;
+	dev->flags		= IFF_NOARP;
 
 	/* set flags according to driver capabilities */
 	if (echo)
 		dev->flags |= IFF_ECHO;
 
-	dev->netdev_ops        = &vcan_netdev_ops;
-	dev->destructor        = free_netdev;
+	dev->netdev_ops		= &vcan_netdev_ops;
+	dev->destructor		= free_netdev;
 }
 
 static struct rtnl_link_ops vcan_link_ops __read_mostly = {
-       .kind           = "vcan",
-       .setup          = vcan_setup,
+	.kind	= "vcan",
+	.setup	= vcan_setup,
 };
 
 static __init int vcan_init_module(void)

--------------040605030902040505030105--
