From: Nik Nyby <nikolas@gnu.org>
Subject: [PATCH] stmmac: Trivial: fix typo in constant name
Date: Mon, 29 Jun 2015 15:39:27 -0400
Message-ID: <1435606767-9708-1-git-send-email-nikolas@gnu.org>
Cc: Nik Nyby <nikolas@gnu.org>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org, trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eggs.gnu.org ([208.118.235.92]:38745 "EHLO eggs.gnu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114AbbF2Tjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 15:39:49 -0400
Received: from Debian-exim by eggs.gnu.org with spam-scanned (Exim 4.71)
	(envelope-from <nikolas@gnu.org>)
	id 1Z9euA-0002Oa-BJ
	for netdev@vger.kernel.org; Mon, 29 Jun 2015 15:39:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a typo in the MMC_RX_CRC_ERROR constant.

Signed-off-by: Nik Nyby <nikolas@gnu.org>
---
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index 08c483b..3f20bb1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -73,7 +73,7 @@
 #define MMC_RX_OCTETCOUNT_G		0x00000188
 #define MMC_RX_BROADCASTFRAME_G		0x0000018c
 #define MMC_RX_MULTICASTFRAME_G		0x00000190
-#define MMC_RX_CRC_ERRROR		0x00000194
+#define MMC_RX_CRC_ERROR		0x00000194
 #define MMC_RX_ALIGN_ERROR		0x00000198
 #define MMC_RX_RUN_ERROR		0x0000019C
 #define MMC_RX_JABBER_ERROR		0x000001A0
@@ -196,7 +196,7 @@ void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc)
 	mmc->mmc_rx_octetcount_g += readl(ioaddr + MMC_RX_OCTETCOUNT_G);
 	mmc->mmc_rx_broadcastframe_g += readl(ioaddr + MMC_RX_BROADCASTFRAME_G);
 	mmc->mmc_rx_multicastframe_g += readl(ioaddr + MMC_RX_MULTICASTFRAME_G);
-	mmc->mmc_rx_crc_error += readl(ioaddr + MMC_RX_CRC_ERRROR);
+	mmc->mmc_rx_crc_error += readl(ioaddr + MMC_RX_CRC_ERROR);
 	mmc->mmc_rx_align_error += readl(ioaddr + MMC_RX_ALIGN_ERROR);
 	mmc->mmc_rx_run_error += readl(ioaddr + MMC_RX_RUN_ERROR);
 	mmc->mmc_rx_jabber_error += readl(ioaddr + MMC_RX_JABBER_ERROR);
-- 
2.1.4
