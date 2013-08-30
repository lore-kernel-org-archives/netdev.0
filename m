From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 13/31] net: ks8842: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:58:30 +0900
Message-ID: <003d01cea53d$9222def0$b6689cd0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:39775 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab3H3E6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:58:34 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00K2HV4SWJ00@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:58:31 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ks8842.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index 94b3bd6..0951f7a 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1148,7 +1148,7 @@ static int ks8842_probe(struct platform_device *pdev)
 	struct resource *iomem;
 	struct net_device *netdev;
 	struct ks8842_adapter *adapter;
-	struct ks8842_platform_data *pdata = pdev->dev.platform_data;
+	struct ks8842_platform_data *pdata = dev_get_platdata(&pdev->dev);
 	u16 id;
 	unsigned i;
 
-- 
1.7.10.4
