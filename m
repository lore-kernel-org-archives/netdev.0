From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net/phy: add missing kernel-doc
Date: Mon, 13 Oct 2008 09:15:05 -0700
Message-ID: <20081013091505.61177f48.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:61464 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756404AbYJMQTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 12:19:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc warning, missing description:

Warning(lin2627-g3-kdocfixes//drivers/net/phy/mdio_bus.c:63): No description found for parameter 'd'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/mdio_bus.c |    1 +
 1 file changed, 1 insertion(+)

--- lin2627-g3-kdocfixes.orig/drivers/net/phy/mdio_bus.c
+++ lin2627-g3-kdocfixes/drivers/net/phy/mdio_bus.c
@@ -55,6 +55,7 @@ EXPORT_SYMBOL(mdiobus_alloc);
 
 /**
  * mdiobus_release - mii_bus device release callback
+ * @d: the target struct device that contains the mii_bus
  *
  * Description: called when the last reference to an mii_bus is
  * dropped, to free the underlying memory.
