From: Axel Lin <axel.lin@ingics.com>
Subject: [PATCH] net: phy: aquantia/teranetics: Convert to use
 module_phy_driver macro
Date: Wed, 14 Oct 2015 18:30:48 +0800
Message-ID: <1444818648.6933.1.camel@ingics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36286 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbbJNKax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 06:30:53 -0400
Received: by pabur7 with SMTP id ur7so2011229pab.3
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 03:30:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use module_phy_driver macro to simplify the code a bit.

Signed-off-by: Axel Lin <axel.lin@ingics.com>
---
 drivers/net/phy/aquantia.c   | 15 +--------------
 drivers/net/phy/teranetics.c | 15 +--------------
 2 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/drivers/net/phy/aquantia.c b/drivers/net/phy/aquantia.c
index d6111af..f1936b7 100644
--- a/drivers/net/phy/aquantia.c
+++ b/drivers/net/phy/aquantia.c
@@ -171,20 +171,7 @@ static struct phy_driver aquantia_driver[] = {
 },
 };
 
-static int __init aquantia_init(void)
-{
-	return phy_drivers_register(aquantia_driver,
-				    ARRAY_SIZE(aquantia_driver));
-}
-
-static void __exit aquantia_exit(void)
-{
-	return phy_drivers_unregister(aquantia_driver,
-				      ARRAY_SIZE(aquantia_driver));
-}
-
-module_init(aquantia_init);
-module_exit(aquantia_exit);
+module_phy_driver(aquantia_driver);
 
 static struct mdio_device_id __maybe_unused aquantia_tbl[] = {
 	{ PHY_ID_AQ1202, 0xfffffff0 },
diff --git a/drivers/net/phy/teranetics.c b/drivers/net/phy/teranetics.c
index 91e1bec..07463fc 100644
--- a/drivers/net/phy/teranetics.c
+++ b/drivers/net/phy/teranetics.c
@@ -112,20 +112,7 @@ static struct phy_driver teranetics_driver[] = {
 },
 };
 
-static int __init teranetics_init(void)
-{
-	return phy_drivers_register(teranetics_driver,
-				    ARRAY_SIZE(teranetics_driver));
-}
-
-static void __exit teranetics_exit(void)
-{
-	return phy_drivers_unregister(teranetics_driver,
-				      ARRAY_SIZE(teranetics_driver));
-}
-
-module_init(teranetics_init);
-module_exit(teranetics_exit);
+module_phy_driver(teranetics_driver);
 
 static struct mdio_device_id __maybe_unused teranetics_tbl[] = {
 	{ PHY_ID_TN2020, 0xffffffff },
-- 
2.1.4
