From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 4/5] net: mdio-gpio: Use module_platform_driver()
Date: Wed, 20 Mar 2013 17:11:31 +0530
Message-ID: <1363779692-4395-4-git-send-email-sachin.kamat@linaro.org>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:48721 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491Ab3CTLwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 07:52:49 -0400
Received: by mail-da0-f43.google.com with SMTP id u36so957480dak.16
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 04:52:48 -0700 (PDT)
In-Reply-To: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver macro removes some boilerplate and
simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/phy/mdio-gpio.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 2727498..a47f923 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -235,17 +235,7 @@ static struct platform_driver mdio_gpio_driver = {
 	},
 };
 
-static int __init mdio_gpio_init(void)
-{
-	return platform_driver_register(&mdio_gpio_driver);
-}
-module_init(mdio_gpio_init);
-
-static void __exit mdio_gpio_exit(void)
-{
-	platform_driver_unregister(&mdio_gpio_driver);
-}
-module_exit(mdio_gpio_exit);
+module_platform_driver(mdio_gpio_driver);
 
 MODULE_ALIAS("platform:mdio-gpio");
 MODULE_AUTHOR("Laurent Pinchart, Paulius Zaleckas");
-- 
1.7.4.1
