From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: fix GMAC syn ID
Date: Wed, 22 Aug 2012 12:26:15 +0200
Message-ID: <1345631176-29494-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Gianni Antoniazzi <gianni.antoniazzi-ext@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:57611 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751704Ab2HVK00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 06:26:26 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 34838EE
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 10:26:23 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CFD9827E9
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 10:26:23 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erroneously the DWMAC_CORE_3_40 was set to 34 instead of 0x34.
This can generate problems when run on old chips because
the driver assumes that there are the extra 16 regs available
for perfect filtering.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Gianni Antoniazzi <gianni.antoniazzi-ext@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index f90fcb5..b4c44a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -229,6 +229,6 @@ enum rtc_control {
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
 /* Synopsys Core versions */
-#define	DWMAC_CORE_3_40	34
+#define	DWMAC_CORE_3_40	0x34
 
 extern const struct stmmac_dma_ops dwmac1000_dma_ops;
-- 
1.7.4.4
