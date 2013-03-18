From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/3] net: dm9000: Use module_platform_driver()
Date: Mon, 18 Mar 2013 17:20:46 +0530
Message-ID: <1363607448-17369-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:61048 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3CRMBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:01:52 -0400
Received: by mail-pb0-f48.google.com with SMTP id wy12so6310665pbc.7
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 05:01:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and makes
the code simpler.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
This series compile tested against linux-next tree (20130318).
---
 drivers/net/ethernet/davicom/dm9000.c |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 8cdf025..f38f677 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1687,22 +1687,7 @@ static struct platform_driver dm9000_driver = {
 	.remove  = dm9000_drv_remove,
 };
 
-static int __init
-dm9000_init(void)
-{
-	printk(KERN_INFO "%s Ethernet Driver, V%s\n", CARDNAME, DRV_VERSION);
-
-	return platform_driver_register(&dm9000_driver);
-}
-
-static void __exit
-dm9000_cleanup(void)
-{
-	platform_driver_unregister(&dm9000_driver);
-}
-
-module_init(dm9000_init);
-module_exit(dm9000_cleanup);
+module_platform_driver(dm9000_driver);
 
 MODULE_AUTHOR("Sascha Hauer, Ben Dooks");
 MODULE_DESCRIPTION("Davicom DM9000 network driver");
-- 
1.7.4.1
