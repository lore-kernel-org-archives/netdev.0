From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/3] net: at91_ether: Use module_platform_driver_probe macro
Date: Tue,  5 Mar 2013 10:01:21 +0530
Message-ID: <1362457882-12892-2-git-send-email-sachin.kamat@linaro.org>
References: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:40967 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932483Ab3CEEmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 23:42:03 -0500
Received: by mail-pb0-f41.google.com with SMTP id um15so3905025pbc.28
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 20:42:02 -0800 (PST)
In-Reply-To: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver_probe() eliminates the boilerplate and simplifies
the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/at91_ether.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 3becdb2..1a57e16 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -519,18 +519,7 @@ static struct platform_driver at91ether_driver = {
 	},
 };
 
-static int __init at91ether_init(void)
-{
-	return platform_driver_probe(&at91ether_driver, at91ether_probe);
-}
-
-static void __exit at91ether_exit(void)
-{
-	platform_driver_unregister(&at91ether_driver);
-}
-
-module_init(at91ether_init)
-module_exit(at91ether_exit)
+module_platform_driver_probe(at91ether_driver, at91ether_probe);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AT91RM9200 EMAC Ethernet driver");
-- 
1.7.4.1
