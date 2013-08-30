From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 14/31] net: ks8851-ml: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:59:01 +0900
Message-ID: <003e01cea53d$a5015880$ef040980$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:9161 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab3H3E7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:59:03 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB0026TV4BOIP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:59:02 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 9f3f5db..0fba153 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1636,7 +1636,7 @@ static int ks8851_probe(struct platform_device *pdev)
 	} else {
 		struct ks8851_mll_platform_data *pdata;
 
-		pdata = pdev->dev.platform_data;
+		pdata = dev_get_platdata(&pdev->dev);
 		if (!pdata) {
 			netdev_err(netdev, "No platform data\n");
 			err = -ENODEV;
-- 
1.7.10.4
