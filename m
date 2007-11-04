From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] phylib: Silence driver registration
Date: Sun, 4 Nov 2007 16:09:23 -0600
Message-ID: <20071104220923.GB13657@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:48483 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbXKDWAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 17:00:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It gets quite verbose to see every single PHY driver being registered
by default.

Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c046121..f6e4848 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -706,7 +706,7 @@ int phy_driver_register(struct phy_driver *new_driver)
 		return retval;
 	}
 
-	pr_info("%s: Registered new driver\n", new_driver->name);
+	pr_debug("%s: Registered new driver\n", new_driver->name);
 
 	return 0;
 }
