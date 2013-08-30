From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 07/31] net: ep93xx_eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:54:37 +0900
Message-ID: <003701cea53d$0718ffb0$154aff10$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Hartley Sweeten' <hsweeten@visionengravers.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58818 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab3H3Eyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:54:38 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00BYIUYS9MN0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:54:36 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index e3d4ec8..ec88de4 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -814,7 +814,7 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 
 	if (pdev == NULL)
 		return -ENODEV;
-	data = pdev->dev.platform_data;
+	data = dev_get_platdata(&pdev->dev);
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	irq = platform_get_irq(pdev, 0);
-- 
1.7.10.4
