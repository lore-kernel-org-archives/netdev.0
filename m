From: varkabhadram@gmail.com
Subject: [PATCH net v2 4/7] net: cpmac: fix cpmac driver structure
Date: Thu, 10 Jul 2014 11:05:42 +0530
Message-ID: <1404970545-26508-5-git-send-email-varkabhadram@gmail.com>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:49777 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaGJFhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 01:37:16 -0400
Received: by mail-pa0-f54.google.com with SMTP id et14so10536355pad.13
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 22:37:15 -0700 (PDT)
In-Reply-To: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch changes to style of declarattion which follows every driver

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 9faf669..1520c19 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1187,9 +1187,11 @@ static int cpmac_remove(struct platform_device *pdev)
 }
 
 static struct platform_driver cpmac_driver = {
-	.driver.name = "cpmac",
-	.driver.owner = THIS_MODULE,
-	.probe = cpmac_probe,
+	.driver = {
+		.name 	= "cpmac",
+		.owner 	= THIS_MODULE,
+	},
+	.probe 	= cpmac_probe,
 	.remove = cpmac_remove,
 };
 
-- 
1.7.9.5
