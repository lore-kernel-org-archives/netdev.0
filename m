From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 4/6] stmmac: dwmac-sti: remove useless tx_retime_srcs
Date: Wed, 26 Feb 2014 09:01:05 +0100
Message-ID: <1393401667-6452-5-git-send-email-peppe.cavallaro@st.com>
References: <1393401667-6452-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:56108 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbaBZICi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 03:02:38 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1FDBF1BE
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:02:37 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 06FB0A98B
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 08:02:37 +0000 (GMT)
In-Reply-To: <1393401667-6452-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to remove the useless tx_retime_srcs definition.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 552bbc1..e5b366e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -162,14 +162,6 @@ enum {
 	TX_RETIME_SRC_CLKGEN,
 };
 
-static const char *const tx_retime_srcs[] = {
-	[TX_RETIME_SRC_NA] = "",
-	[TX_RETIME_SRC_TXCLK] = "txclk",
-	[TX_RETIME_SRC_CLK_125] = "clk_125",
-	[TX_RETIME_SRC_PHYCLK] = "phyclk",
-	[TX_RETIME_SRC_CLKGEN] = "clkgen",
-};
-
 static u32 tx_retime_val[] = {
 	[TX_RETIME_SRC_TXCLK] = ETH_SEL_TXCLK_NOT_CLK125,
 	[TX_RETIME_SRC_CLK_125] = 0x0,
-- 
1.7.4.4
