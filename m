From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 15/15] mdio: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:36 -0800
Message-ID: <20090226201950.701314568@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38670 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755834AbZBZUUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:21 -0500
Content-Disposition: inline; filename=mdio-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/phy/mdio_bus.c	2009-02-26 12:03:59.000000000 -0800
+++ b/drivers/net/phy/mdio_bus.c	2009-02-26 12:04:14.000000000 -0800
@@ -99,7 +99,7 @@ int mdiobus_register(struct mii_bus *bus
 	bus->dev.parent = bus->parent;
 	bus->dev.class = &mdio_bus_class;
 	bus->dev.groups = NULL;
-	dev_set_name(&bus->dev, bus->id);
+	dev_set_name(&bus->dev, "%s", bus->id);
 
 	err = device_register(&bus->dev);
 	if (err) {

-- 

