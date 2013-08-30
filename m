From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 03/31] net: au1000_eth: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:51:45 +0900
Message-ID: <003301cea53c$a0df4290$e29dc7b0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:65312 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3H3Evr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:51:47 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB002TMUTJOIO0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:51:45 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/amd/au1000_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index ceb45bc..91d52b4 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1131,7 +1131,7 @@ static int au1000_probe(struct platform_device *pdev)
 	writel(0, aup->enable);
 	aup->mac_enabled = 0;
 
-	pd = pdev->dev.platform_data;
+	pd = dev_get_platdata(&pdev->dev);
 	if (!pd) {
 		dev_info(&pdev->dev, "no platform_data passed,"
 					" PHY search on MAC0\n");
-- 
1.7.10.4
