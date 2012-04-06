From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] stmmac: fix build when CONFIG_OF is enable
Date: Fri,  6 Apr 2012 09:25:17 +0200
Message-ID: <1333697117-25592-1-git-send-email-peppe.cavallaro@st.com>
References: <20120405132515.e61465875407a452c1a6f78e@canb.auug.org.au>
Cc: davem@davemloft.net, sfr@canb.auug.org.au,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:38532 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752008Ab2DFHZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 03:25:46 -0400
In-Reply-To: <20120405132515.e61465875407a452c1a6f78e@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 116529a..12bd221 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -50,7 +50,7 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
 	 * once needed on other platforms.
 	 */
 	if (of_device_is_compatible(np, "st,spear600-gmac")) {
-		plat->pbl = 8;
+		plat->dma_cfg->pbl = 8;
 		plat->has_gmac = 1;
 		plat->pmt = 1;
 	}
-- 
1.7.4.4
