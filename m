From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 3/5] net: au1k_ir: Use module_platform_driver()
Date: Wed, 20 Mar 2013 17:11:30 +0530
Message-ID: <1363779692-4395-3-git-send-email-sachin.kamat@linaro.org>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:43785 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831Ab3CTL7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 07:59:07 -0400
Received: by mail-da0-f54.google.com with SMTP id p1so948870dad.27
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 04:59:07 -0700 (PDT)
In-Reply-To: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and
simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/au1k_ir.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 56f1e6d..7a1f684 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -953,18 +953,7 @@ static struct platform_driver au1k_irda_driver = {
 	.remove		= au1k_irda_remove,
 };
 
-static int __init au1k_irda_load(void)
-{
-	return platform_driver_register(&au1k_irda_driver);
-}
-
-static void __exit au1k_irda_unload(void)
-{
-	return platform_driver_unregister(&au1k_irda_driver);
-}
+module_platform_driver(au1k_irda_driver);
 
 MODULE_AUTHOR("Pete Popov <ppopov@mvista.com>");
 MODULE_DESCRIPTION("Au1000 IrDA Device Driver");
-
-module_init(au1k_irda_load);
-module_exit(au1k_irda_unload);
-- 
1.7.4.1
