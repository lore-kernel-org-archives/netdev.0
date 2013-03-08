From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/5] Supject: phy: make local function static
Date: Fri, 08 Mar 2013 11:07:41 -0800
Message-ID: <20130308190809.052958493@vyatta.com>
References: <20130308190739.260966567@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:37277 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab3CHTXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 14:23:33 -0500
Content-Disposition: inline; filename=phy-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/phy/lxt.c	2013-03-08 10:33:17.950142115 -0800
+++ b/drivers/net/phy/lxt.c	2013-03-08 10:33:22.210142229 -0800
@@ -159,7 +159,7 @@ static int lxt973a2_update_link(struct p
 	return 0;
 }
 
-int lxt973a2_read_status(struct phy_device *phydev)
+static int lxt973a2_read_status(struct phy_device *phydev)
 {
 	int adv;
 	int err;
