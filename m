From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] phy: fix kernel-doc notation
Date: Mon, 28 Apr 2008 10:58:22 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804281056520.30172@shark.he.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:40928 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1763309AbYD1R6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 13:58:24 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 10:58:22 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc warning:
Warning(linux-2.6.25-git11//drivers/net/phy/phy_device.c:275): No description found for parameter 'bus_id'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/phy_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.25-git11.orig/drivers/net/phy/phy_device.c
+++ linux-2.6.25-git11/drivers/net/phy/phy_device.c
@@ -256,7 +256,7 @@ void phy_prepare_link(struct phy_device 
 /**
  * phy_connect - connect an ethernet device to a PHY device
  * @dev: the network device to connect
- * @phy_id: the PHY device to connect
+ * @bus_id: the id string of the PHY device to connect
  * @handler: callback function for state change notifications
  * @flags: PHY device's dev_flags
  * @interface: PHY device's interface
