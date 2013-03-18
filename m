From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 3/3] net: ftgmac100: Use module_platform_driver()
Date: Mon, 18 Mar 2013 17:20:48 +0530
Message-ID: <1363607448-17369-3-git-send-email-sachin.kamat@linaro.org>
References: <1363607448-17369-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:33445 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3CRMB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:01:57 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so6317948pbc.9
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 05:01:57 -0700 (PDT)
In-Reply-To: <1363607448-17369-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and makes
the code simpler.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Po-Yu Chuang <ratbert@faraday-tech.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 0e817e6..21b85fb 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1349,22 +1349,7 @@ static struct platform_driver ftgmac100_driver = {
 	},
 };
 
-/******************************************************************************
- * initialization / finalization
- *****************************************************************************/
-static int __init ftgmac100_init(void)
-{
-	pr_info("Loading version " DRV_VERSION " ...\n");
-	return platform_driver_register(&ftgmac100_driver);
-}
-
-static void __exit ftgmac100_exit(void)
-{
-	platform_driver_unregister(&ftgmac100_driver);
-}
-
-module_init(ftgmac100_init);
-module_exit(ftgmac100_exit);
+module_platform_driver(ftgmac100_driver);
 
 MODULE_AUTHOR("Po-Yu Chuang <ratbert@faraday-tech.com>");
 MODULE_DESCRIPTION("FTGMAC100 driver");
-- 
1.7.4.1
