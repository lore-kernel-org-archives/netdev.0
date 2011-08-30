From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/9] stmmac: remove the STBus bridge setting from the GMAC code (v2)
Date: Tue, 30 Aug 2011 16:20:56 +0200
Message-ID: <1314714064-29101-2-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:34031 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754169Ab1H3OVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:21 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BB52395
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:19 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 85F81226C
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:19 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes a piece of code (actually commented)
only useful for some ST platforms in the past.

This kind of setting now can be done by using the platform
callbacks provided in linux/stmmac.h (see the stmmac.txt for
further details).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/dwmac1000_core.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 0f63b3c..eea184a 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -37,9 +37,6 @@ static void dwmac1000_core_init(void __iomem *ioaddr)
 	value |= GMAC_CORE_INIT;
 	writel(value, ioaddr + GMAC_CONTROL);
 
-	/* STBus Bridge Configuration */
-	/*writel(0xc5608, ioaddr + 0x00007000);*/
-
 	/* Freeze MMC counters */
 	writel(0x8, ioaddr + GMAC_MMC_CTRL);
 	/* Mask GMAC interrupts */
-- 
1.7.4.4
