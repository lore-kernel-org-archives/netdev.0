From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/5] net: s6gmac: Use module_platform_driver()
Date: Wed, 20 Mar 2013 17:11:29 +0530
Message-ID: <1363779692-4395-2-git-send-email-sachin.kamat@linaro.org>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:40634 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491Ab3CTLwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 07:52:44 -0400
Received: by mail-da0-f43.google.com with SMTP id u36so957443dak.16
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 04:52:43 -0700 (PDT)
In-Reply-To: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and
simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/s6gmac.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 21683e2..cd5f4e2 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1053,20 +1053,7 @@ static struct platform_driver s6gmac_driver = {
 	},
 };
 
-static int __init s6gmac_init(void)
-{
-	printk(KERN_INFO DRV_PRMT "S6 GMAC ethernet driver\n");
-	return platform_driver_register(&s6gmac_driver);
-}
-
-
-static void __exit s6gmac_exit(void)
-{
-	platform_driver_unregister(&s6gmac_driver);
-}
-
-module_init(s6gmac_init);
-module_exit(s6gmac_exit);
+module_platform_driver(s6gmac_driver);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("S6105 on chip Ethernet driver");
-- 
1.7.4.1
