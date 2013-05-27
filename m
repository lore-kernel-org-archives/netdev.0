From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net/phy: Use module_spi_driver in spi_ks8995.c
Date: Mon, 27 May 2013 17:21:39 +0530
Message-ID: <1369655499-17192-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org, juhosg@openwrt.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:38529 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab3E0MFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 08:05:37 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so6710552pbb.27
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 05:05:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_spi_driver() removes some boilerplate and makes the code
simpler.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/phy/spi_ks8995.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index d11c93e..f3bea13 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -354,19 +354,7 @@ static struct spi_driver ks8995_driver = {
 	.remove	  = ks8995_remove,
 };
 
-static int __init ks8995_init(void)
-{
-	pr_info(DRV_DESC " version " DRV_VERSION "\n");
-
-	return spi_register_driver(&ks8995_driver);
-}
-module_init(ks8995_init);
-
-static void __exit ks8995_exit(void)
-{
-	spi_unregister_driver(&ks8995_driver);
-}
-module_exit(ks8995_exit);
+module_spi_driver(ks8995_driver);
 
 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_VERSION(DRV_VERSION);
-- 
1.7.9.5
