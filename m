From: Jan Luebbe <jlu@pengutronix.de>
Subject: [PATCH] net: fix macvtap type name in Kconfig
Date: Mon, 10 Feb 2014 21:40:51 +0100
Message-ID: <1392064851-25879-1-git-send-email-jlu@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:54222 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbaBJUqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 15:46:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink kind (and iproute2 type option) is actually called
'macvtap', not 'macvlan'.

Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
---
 drivers/net/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f342278..494b888 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -139,7 +139,7 @@ config MACVTAP
 	  This adds a specialized tap character device driver that is based
 	  on the MAC-VLAN network interface, called macvtap. A macvtap device
 	  can be added in the same way as a macvlan device, using 'type
-	  macvlan', and then be accessed through the tap user space interface.
+	  macvtap', and then be accessed through the tap user space interface.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called macvtap.
-- 
1.8.5.2
