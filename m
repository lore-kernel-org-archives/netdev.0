From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] netdev/phy: Prototype of_mdio_find_bus()
Date: Tue,  9 Oct 2012 17:55:43 +0900
Message-ID: <1349772944-14289-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: "David S. Miller" <davem@davemloft.net>,
	David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:57582 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754301Ab2JII4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 04:56:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that of_mdio_find_bus() matches the prototype in the header (and
stop sparse complaining) by including the header with the prototype.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/phy/mdio_bus.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 170eb41..c1ef300 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/device.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-- 
1.7.10.4
