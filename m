From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 3/3] phy.c: fix kernel-doc warnings
Date: Mon, 9 Aug 2010 16:41:59 -0700
Message-ID: <20100809164159.c81cd1c4.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21400 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757160Ab0HIXnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 19:43:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix phy.c kernel-doc notation:

Warning(drivers/net/phy/phy.c:313): No description found for parameter 'ifr'
Warning(drivers/net/phy/phy.c:313): Excess function parameter 'mii_data' description in 'phy_mii_ioctl'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/phy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.35-git8.orig/drivers/net/phy/phy.c
+++ linux-2.6.35-git8/drivers/net/phy/phy.c
@@ -301,7 +301,7 @@ EXPORT_SYMBOL(phy_ethtool_gset);
 /**
  * phy_mii_ioctl - generic PHY MII ioctl interface
  * @phydev: the phy_device struct
- * @mii_data: MII ioctl data
+ * @ifr: &struct ifreq for socket ioctl's
  * @cmd: ioctl cmd to execute
  *
  * Note that this function is currently incompatible with the
