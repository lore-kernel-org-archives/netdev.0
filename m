From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] stmmac: fix a typo in the macro used to mask the mmc irq
Date: Wed, 22 Aug 2012 12:26:16 +0200
Message-ID: <1345631176-29494-2-git-send-email-peppe.cavallaro@st.com>
References: <1345631176-29494-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:60695 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753363Ab2HVK03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 06:26:29 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A7458D4
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 10:26:27 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5F8BF27E9
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 10:26:27 +0000 (GMT)
In-Reply-To: <1345631176-29494-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the name of the macro used to mask the
mmc interrupt: erroneously it was used: MMC_DEFAUL_MASK.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index c07cfe9..0c74a70 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -33,7 +33,7 @@
 #define MMC_TX_INTR		0x00000108	/* MMC TX Interrupt */
 #define MMC_RX_INTR_MASK	0x0000010c	/* MMC Interrupt Mask */
 #define MMC_TX_INTR_MASK	0x00000110	/* MMC Interrupt Mask */
-#define MMC_DEFAUL_MASK		0xffffffff
+#define MMC_DEFAULT_MASK		0xffffffff
 
 /* MMC TX counter registers */
 
@@ -147,8 +147,8 @@ void dwmac_mmc_ctrl(void __iomem *ioaddr, unsigned int mode)
 /* To mask all all interrupts.*/
 void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
 {
-	writel(MMC_DEFAUL_MASK, ioaddr + MMC_RX_INTR_MASK);
-	writel(MMC_DEFAUL_MASK, ioaddr + MMC_TX_INTR_MASK);
+	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_INTR_MASK);
+	writel(MMC_DEFAULT_MASK, ioaddr + MMC_TX_INTR_MASK);
 }
 
 /* This reads the MAC core counters (if actaully supported).
-- 
1.7.4.4
