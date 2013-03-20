From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 5/5] net: mdio-octeon: Use module_platform_driver()
Date: Wed, 20 Mar 2013 17:11:32 +0530
Message-ID: <1363779692-4395-5-git-send-email-sachin.kamat@linaro.org>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:39524 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932787Ab3CTLwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 07:52:51 -0400
Received: by mail-pb0-f48.google.com with SMTP id wy12so1287868pbc.35
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 04:52:51 -0700 (PDT)
In-Reply-To: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and
simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/phy/mdio-octeon.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 09297fe..c2c878d 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -197,18 +197,7 @@ void octeon_mdiobus_force_mod_depencency(void)
 }
 EXPORT_SYMBOL(octeon_mdiobus_force_mod_depencency);
 
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
1.7.4.1
