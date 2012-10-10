From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH 3.6.0- 1/3] net/mdio-gpio: use module_platform_driver macro
Date: Wed, 10 Oct 2012 19:29:02 +0100
Message-ID: <1349893742-6833-1-git-send-email-srinivas.kandagatla@st.com>
Cc: srinivas.kandagatla@st.com, bordug@ru.mvista.com,
	netdev@vger.kernel.org, david.daney@cavium.com,
	linville@tuxdriver.com, kaloz@openwrt.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:41618 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751539Ab2JJSaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 14:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch removes some code duplication by using
module_platform_driver.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/phy/mdio-gpio.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 899274f..d5d1624 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -231,18 +231,7 @@ static struct platform_driver mdio_gpio_driver = {
 		.of_match_table = mdio_gpio_of_match,
 	},
 };
-
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
1.7.0.4
