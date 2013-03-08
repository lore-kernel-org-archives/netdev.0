From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/5] phy: vitesse make vsc824x_add_skew static
Date: Fri, 08 Mar 2013 11:07:42 -0800
Message-ID: <20130308190809.252350839@vyatta.com>
References: <20130308190739.260966567@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:37276 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab3CHTXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 14:23:30 -0500
Content-Disposition: inline; filename=vitesse-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function is only used in this file, should be static and not
an exported symbol.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/phy/vitesse.c	2013-03-08 10:33:16.126142066 -0800
+++ b/drivers/net/phy/vitesse.c	2013-03-08 10:33:22.818142246 -0800
@@ -61,7 +61,7 @@ MODULE_DESCRIPTION("Vitesse PHY driver")
 MODULE_AUTHOR("Kriston Carson");
 MODULE_LICENSE("GPL");
 
-int vsc824x_add_skew(struct phy_device *phydev)
+static int vsc824x_add_skew(struct phy_device *phydev)
 {
 	int err;
 	int extcon;
@@ -81,7 +81,6 @@ int vsc824x_add_skew(struct phy_device *
 
 	return err;
 }
-EXPORT_SYMBOL(vsc824x_add_skew);
 
 static int vsc824x_config_init(struct phy_device *phydev)
 {
