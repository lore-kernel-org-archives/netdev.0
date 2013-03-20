From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/5] net: ks8695net: Use module_platform_driver()
Date: Wed, 20 Mar 2013 17:11:28 +0530
Message-ID: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:48381 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119Ab3CTLwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 07:52:42 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so1309080pbc.28
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 04:52:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and
simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/micrel/ks8695net.c |   20 +-------------------
 1 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index 07a6ebc..b6c60fd 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1622,25 +1622,7 @@ static struct platform_driver ks8695_driver = {
 	.resume		= ks8695_drv_resume,
 };
 
-/* Module interface */
-
-static int __init
-ks8695_init(void)
-{
-	printk(KERN_INFO "%s Ethernet driver, V%s\n",
-	       MODULENAME, MODULEVERSION);
-
-	return platform_driver_register(&ks8695_driver);
-}
-
-static void __exit
-ks8695_cleanup(void)
-{
-	platform_driver_unregister(&ks8695_driver);
-}
-
-module_init(ks8695_init);
-module_exit(ks8695_cleanup);
+module_platform_driver(ks8695_driver);
 
 MODULE_AUTHOR("Simtec Electronics");
 MODULE_DESCRIPTION("Micrel KS8695 (Centaur) Ethernet driver");
-- 
1.7.4.1
