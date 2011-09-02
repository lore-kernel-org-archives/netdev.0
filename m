From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/9] stmmac: remove the STBus bridge setting from the GMAC code (v3)
Date: Fri,  2 Sep 2011 09:51:35 +0200
Message-ID: <1314949903-26137-2-git-send-email-peppe.cavallaro@st.com>
References: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:37161 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757775Ab1IBHwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 03:52:14 -0400
In-Reply-To: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
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
