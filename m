From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/2] net: phy: at803x: don't pass function pointers with &
Date: Sat, 21 Sep 2013 16:53:01 +0200
Message-ID: <1379775182-1271-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, mugunthanvnm@ti.com, ujhelyi.m@gmail.com,
	sergei.shtylyov@cogentembedded.com, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56355 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567Ab3IUOxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Sep 2013 10:53:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a cosmetic cleanup.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/at803x.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index ac22283..4179228 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -163,8 +163,8 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol	= at803x_get_wol,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
@@ -178,8 +178,8 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol	= at803x_get_wol,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
@@ -193,8 +193,8 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol	= at803x_get_wol,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
-- 
1.8.3.1
