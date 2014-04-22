From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH] net/phy: Remove return value for void function
Date: Tue, 22 Apr 2014 14:21:47 -0500
Message-ID: <1398194507-9387-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <joe@perches.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0139.outbound.protection.outlook.com ([207.46.163.139]:26149
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752128AbaDVTVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 15:21:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was caught when using a spatch (aka. coccinelle) script
written by Joe Perches.

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
---
 drivers/net/phy/at803x.c  | 3 +--
 drivers/net/phy/smsc.c    | 3 +--
 drivers/net/phy/vitesse.c | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 643464d..07d8a11 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -283,8 +283,7 @@ static int __init atheros_init(void)
 
 static void __exit atheros_exit(void)
 {
-	return phy_drivers_unregister(at803x_driver,
-				      ARRAY_SIZE(at803x_driver));
+	phy_drivers_unregister(at803x_driver, ARRAY_SIZE(at803x_driver));
 }
 
 module_init(atheros_init);
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 11f3481..180c494 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -249,8 +249,7 @@ static int __init smsc_init(void)
 
 static void __exit smsc_exit(void)
 {
-	return phy_drivers_unregister(smsc_phy_driver,
-		ARRAY_SIZE(smsc_phy_driver));
+	phy_drivers_unregister(smsc_phy_driver, ARRAY_SIZE(smsc_phy_driver));
 }
 
 MODULE_DESCRIPTION("SMSC PHY driver");
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 14372c6..5dc0935d 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -319,8 +319,7 @@ static int __init vsc82xx_init(void)
 
 static void __exit vsc82xx_exit(void)
 {
-	return phy_drivers_unregister(vsc82xx_driver,
-		ARRAY_SIZE(vsc82xx_driver));
+	phy_drivers_unregister(vsc82xx_driver, ARRAY_SIZE(vsc82xx_driver));
 }
 
 module_init(vsc82xx_init);
-- 
1.8.3.1
