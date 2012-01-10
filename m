From: Stefan Roese <sr@denx.de>
Subject: [PATCH] stmmac: Add missing LF to pr_info() in stmmac_main.c
Date: Tue, 10 Jan 2012 12:47:51 +0100
Message-ID: <1326196071-10341-1-git-send-email-sr@denx.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:8839 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147Ab2AJLxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 06:53:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise the output looks like this:

...
STMMAC - user ID: 0x10, Synopsys ID: 0x32
 No HW DMA feature register supported
 Normal descriptors
 Remote wake-up capable
 Checksum Offload Engine supported
 No MAC Management Counters availableIP-Config: Complete:
     device=eth0, addr=192.168.20.42, mask=255.255.0.0, gw=192.168.1.254,
...

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3738b47..ee85a14 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -772,7 +772,7 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 		dwmac_mmc_ctrl(priv->ioaddr, mode);
 		memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
 	} else
-		pr_info(" No MAC Management Counters available");
+		pr_info(" No MAC Management Counters available\n");
 }
 
 static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
-- 
1.7.8.3
