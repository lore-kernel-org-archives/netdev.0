From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.6.0- 2/3] net/mdio-octeon: use module_platform_driver macro
Date: Wed, 10 Oct 2012 19:29:11 +0100
Message-ID: <1349893751-6867-1-git-send-email-srinivas.kandagatla@st.com>
Cc: srinivas.kandagatla@st.com, bordug@ru.mvista.com,
	netdev@vger.kernel.org, david.daney@cavium.com,
	linville@tuxdriver.com, kaloz@openwrt.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:37992 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752293Ab2JJSa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 14:30:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes some code duplication by using
module_platform_driver.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/phy/mdio-octeon.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index d4015aa..84f7c47 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -196,19 +196,7 @@ void octeon_mdiobus_force_mod_depencency(void)
 	/* Let ethernet drivers force us to be loaded.  */
 }
 EXPORT_SYMBOL(octeon_mdiobus_force_mod_depencency);
-
-static int __init octeon_mdiobus_mod_init(void)
-{
-	return platform_driver_register(&octeon_mdiobus_driver);
-}
-
-static void __exit octeon_mdiobus_mod_exit(void)
-{
-	platform_driver_unregister(&octeon_mdiobus_driver);
-}
-
-module_init(octeon_mdiobus_mod_init);
-module_exit(octeon_mdiobus_mod_exit);
+module_platform_driver(octeon_mdiobus_driver);
 
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_VERSION(DRV_VERSION);
-- 
1.7.0.4
