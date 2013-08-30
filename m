From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 29/31] net: ixp4xx_eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:08:22 +0900
Message-ID: <004d01cea53e$f3266c20$d9734460$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Krzysztof Halasa' <khc@pm.waw.pl>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:16453 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab3H3FI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:08:28 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00LTPVK3WZJ0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:08:22 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 3d689fc..e78802e 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1384,7 +1384,7 @@ static int eth_init_one(struct platform_device *pdev)
 {
 	struct port *port;
 	struct net_device *dev;
-	struct eth_plat_info *plat = pdev->dev.platform_data;
+	struct eth_plat_info *plat = dev_get_platdata(&pdev->dev);
 	u32 regs_phys;
 	char phy_id[MII_BUS_ID_SIZE + 3];
 	int err;
-- 
1.7.10.4
