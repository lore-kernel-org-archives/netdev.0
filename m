From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 16/31] net: sh_eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:00:11 +0900
Message-ID: <004001cea53d$ce733d50$6b59b7f0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:60290 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab3H3FAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:00:12 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00DDJV7XR5P0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:00:11 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c357076..2aa7676 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2606,7 +2606,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	struct resource *res;
 	struct net_device *ndev = NULL;
 	struct sh_eth_private *mdp = NULL;
-	struct sh_eth_plat_data *pd = pdev->dev.platform_data;
+	struct sh_eth_plat_data *pd = dev_get_platdata(&pdev->dev);
 	const struct platform_device_id *id = platform_get_device_id(pdev);
 
 	/* get base addr */
-- 
1.7.10.4
