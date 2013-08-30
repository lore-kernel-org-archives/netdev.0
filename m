From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 01/31] net: ax88796: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:44:34 +0900
Message-ID: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:63524 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab3H3Eoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:44:34 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB0000UUI9RDP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:44:33 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/8390/ax88796.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index b7232a9..f92f001 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -840,7 +840,7 @@ static int ax_probe(struct platform_device *pdev)
 	ei_local = netdev_priv(dev);
 	ax = to_ax_dev(dev);
 
-	ax->plat = pdev->dev.platform_data;
+	ax->plat = dev_get_platdata(&pdev->dev);
 	platform_set_drvdata(pdev, dev);
 
 	ei_local->rxcr_base = ax->plat->rcr_val;
-- 
1.7.10.4
