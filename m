From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 26/31] net: tsi108: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:06:41 +0900
Message-ID: <004a01cea53e$b6d634d0$24829e70$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:61939 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab3H3FGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:06:42 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00BN9VIN9MO0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:06:40 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/tundra/tsi108_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 01bdc6c..922e1de 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1558,7 +1558,7 @@ tsi108_init_one(struct platform_device *pdev)
 	hw_info *einfo;
 	int err = 0;
 
-	einfo = pdev->dev.platform_data;
+	einfo = dev_get_platdata(&pdev->dev);
 
 	if (NULL == einfo) {
 		printk(KERN_ERR "tsi-eth %d: Missing additional data!\n",
-- 
1.7.10.4
