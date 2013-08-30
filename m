From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 21/31] net: stmmac: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:13:46 +0900
Message-ID: <005a01cea53f$b44fbb90$1cef32b0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Giuseppe Cavallaro' <peppe.cavallaro@st.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:63225 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300Ab3H3FNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:13:50 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00DCTVUDR5Q0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:13:48 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index b34088d..f17dfff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -117,7 +117,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
 
-	plat_dat = pdev->dev.platform_data;
+	plat_dat = dev_get_platdata(&pdev->dev);
 	if (pdev->dev.of_node) {
 		if (!plat_dat)
 			plat_dat = devm_kzalloc(&pdev->dev,
-- 
1.7.10.4
