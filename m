From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Add MODULE_ALIAS
Date: Sat, 20 Jul 2013 16:20:36 -0300
Message-ID: <1374348036-20654-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:53073 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab3GTTUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 15:20:44 -0400
Received: by mail-yh0-f51.google.com with SMTP id 29so178890yhl.38
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 12:20:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Add MODULE_ALIAS, so that auto module loading can work.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d3ad5ea..f0f0e96 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2279,4 +2279,5 @@ static struct platform_driver fec_driver = {
 
 module_platform_driver(fec_driver);
 
+MODULE_ALIAS("platform:"DRIVER_NAME);
 MODULE_LICENSE("GPL");
-- 
1.8.1.2
