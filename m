From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] netdev: fix drivers/net/phy/ kernel-doc warnings
Date: Fri, 08 Jun 2012 17:07:19 -0700
Message-ID: <4FD293B7.6080702@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:43772 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1761343Ab2FIAHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 20:07:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warnings in drivers/net/phy:

Warning(drivers/net/phy/mdio_bus.c:109): No description found for parameter 'mdio_bus_np'
Warning(drivers/net/phy/mdio_bus.c:109): Excess function parameter 'mdio_np' description in 'of_mdio_find_bus'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/phy/mdio_bus.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-35-rc1.orig/drivers/net/phy/mdio_bus.c
+++ lnx-35-rc1/drivers/net/phy/mdio_bus.c
@@ -96,7 +96,7 @@ static int of_mdio_bus_match(struct devi
 }
 /**
  * of_mdio_find_bus - Given an mii_bus node, find the mii_bus.
- * @mdio_np: Pointer to the mii_bus.
+ * @mdio_bus_np: Pointer to the mii_bus.
  *
  * Returns a pointer to the mii_bus, or NULL if none found.
  *
