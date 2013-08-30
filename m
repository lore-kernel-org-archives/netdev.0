From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 25/31] net: davinci_mdio: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:06:02 +0900
Message-ID: <004901cea53e$9ff3bf30$dfdb3d90$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:11053 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab3H3FGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:06:03 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00641VHRTWO0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:06:02 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 7f85143..4ec9265 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -314,7 +314,7 @@ static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 
 static int davinci_mdio_probe(struct platform_device *pdev)
 {
-	struct mdio_platform_data *pdata = pdev->dev.platform_data;
+	struct mdio_platform_data *pdata = dev_get_platdata(&pdev->dev);
 	struct device *dev = &pdev->dev;
 	struct davinci_mdio_data *data;
 	struct resource *res;
-- 
1.7.10.4
