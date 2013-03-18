From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/3] net: ep93xx_eth: Use module_platform_driver()
Date: Mon, 18 Mar 2013 17:20:47 +0530
Message-ID: <1363607448-17369-2-git-send-email-sachin.kamat@linaro.org>
References: <1363607448-17369-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:58752 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3CRMBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:01:54 -0400
Received: by mail-da0-f49.google.com with SMTP id t11so1284031daj.8
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 05:01:54 -0700 (PDT)
In-Reply-To: <1363607448-17369-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and makes
the code simpler.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 354cbb7..67b0388 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -887,18 +887,7 @@ static struct platform_driver ep93xx_eth_driver = {
 	},
 };
 
-static int __init ep93xx_eth_init_module(void)
-{
-	printk(KERN_INFO DRV_MODULE_NAME " version " DRV_MODULE_VERSION " loading\n");
-	return platform_driver_register(&ep93xx_eth_driver);
-}
-
-static void __exit ep93xx_eth_cleanup_module(void)
-{
-	platform_driver_unregister(&ep93xx_eth_driver);
-}
+module_platform_driver(ep93xx_eth_driver);
 
-module_init(ep93xx_eth_init_module);
-module_exit(ep93xx_eth_cleanup_module);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:ep93xx-eth");
-- 
1.7.4.1
