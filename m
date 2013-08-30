From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 05/31] net: at91_ether: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:11:53 +0900
Message-ID: <005701cea53f$70f6fac0$52e4f040$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Nicolas Ferre' <nicolas.ferre@atmel.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:42754 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab3H3FLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:11:54 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00FQSVRIPUP0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:11:53 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cadence/at91_ether.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index bb5d63f..ce75de9 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -304,7 +304,7 @@ MODULE_DEVICE_TABLE(of, at91ether_dt_ids);
 /* Detect MAC & PHY and perform ethernet interface initialization */
 static int __init at91ether_probe(struct platform_device *pdev)
 {
-	struct macb_platform_data *board_data = pdev->dev.platform_data;
+	struct macb_platform_data *board_data = dev_get_platdata(&pdev->dev);
 	struct resource *regs;
 	struct net_device *dev;
 	struct phy_device *phydev;
-- 
1.7.10.4
