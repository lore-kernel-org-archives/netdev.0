From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 08/31] net: dm9000: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:55:14 +0900
Message-ID: <003801cea53d$1db0d7c0$59128740$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:13287 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440Ab3H3EzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:55:16 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00L3FUZ0WZJ0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:55:14 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/davicom/dm9000.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index a13b312..5f5896e 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1384,7 +1384,7 @@ static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
 static int
 dm9000_probe(struct platform_device *pdev)
 {
-	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
+	struct dm9000_plat_data *pdata = dev_get_platdata(&pdev->dev);
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
 	const unsigned char *mac_src;
-- 
1.7.10.4
