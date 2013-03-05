From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 3/3] net: macb: Use module_platform_driver_probe macro
Date: Tue,  5 Mar 2013 10:01:22 +0530
Message-ID: <1362457882-12892-3-git-send-email-sachin.kamat@linaro.org>
References: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:61007 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932885Ab3CEEmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 23:42:05 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so3849612pbc.24
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 20:42:05 -0800 (PST)
In-Reply-To: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver_probe() eliminates the boilerplate and simplifies
the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7903943..3a5d680 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1737,18 +1737,7 @@ static struct platform_driver macb_driver = {
 	},
 };
 
-static int __init macb_init(void)
-{
-	return platform_driver_probe(&macb_driver, macb_probe);
-}
-
-static void __exit macb_exit(void)
-{
-	platform_driver_unregister(&macb_driver);
-}
-
-module_init(macb_init);
-module_exit(macb_exit);
+module_platform_driver_probe(macb_driver, macb_probe);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
-- 
1.7.4.1
