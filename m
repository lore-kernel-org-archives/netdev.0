From: Ed Blake <ed.blake@sondrel.com>
Subject: [PATCH] net: stmmac: dwc-qos: Add suspend / resume support
Date: Tue, 26 Sep 2017 11:43:46 +0100
Message-ID: <1506422626-26058-1-git-send-email-ed.blake@sondrel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ed Blake <ed.blake@sondrel.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0065.outbound.protection.outlook.com ([104.47.1.65]:2784
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935062AbdIZKoI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 06:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add hook to stmmac_pltfr_pm_ops for suspend / resume handling.

Signed-off-by: Ed Blake <ed.blake@sondrel.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
index dd6a2f9..5efef80 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
@@ -511,6 +511,7 @@ static int dwc_eth_dwmac_remove(struct platform_device *pdev)
 	.remove = dwc_eth_dwmac_remove,
 	.driver = {
 		.name           = "dwc-eth-dwmac",
+		.pm             = &stmmac_pltfr_pm_ops,
 		.of_match_table = dwc_eth_dwmac_match,
 	},
 };
-- 
1.9.1
