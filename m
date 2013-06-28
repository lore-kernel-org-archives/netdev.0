From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: stmmac: fixed operator typo
Date: Fri, 28 Jun 2013 16:35:31 +0900
Message-ID: <015701ce73d2$117b9040$3472b0c0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:19318 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab3F1Hfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 03:35:32 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MP300FJFEF6CT20@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 28 Jun 2013 16:35:31 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixed operator typo from & to ==.
Due to incorrect operator, the result is incorrect.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   22 +++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c1ad5f4..f088633 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -788,13 +788,13 @@ static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
 	int interface = priv->plat->interface;
 
 	if (priv->dma_cap.pcs) {
-		if ((interface & PHY_INTERFACE_MODE_RGMII) ||
-		    (interface & PHY_INTERFACE_MODE_RGMII_ID) ||
-		    (interface & PHY_INTERFACE_MODE_RGMII_RXID) ||
-		    (interface & PHY_INTERFACE_MODE_RGMII_TXID)) {
+		if ((interface == PHY_INTERFACE_MODE_RGMII) ||
+		    (interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+		    (interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+		    (interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
 			pr_debug("STMMAC: PCS RGMII support enable\n");
 			priv->pcs = STMMAC_PCS_RGMII;
-		} else if (interface & PHY_INTERFACE_MODE_SGMII) {
+		} else if (interface == PHY_INTERFACE_MODE_SGMII) {
 			pr_debug("STMMAC: PCS SGMII support enable\n");
 			priv->pcs = STMMAC_PCS_SGMII;
 		}
-- 
1.7.10.4
