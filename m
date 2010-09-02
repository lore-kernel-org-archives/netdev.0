From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH v2 06/10] omap: cleanup unused davinci mdio arch code
Date: Thu,  2 Sep 2010 18:03:24 -0400
Message-ID: <1283465008-18606-7-git-send-email-cyril@ti.com>
References: <1283465008-18606-1-git-send-email-cyril@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, nsekhar@ti.com, srk@ti.com,
	omar.ramirez@ti.com, bparrot@ti.com,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:41216 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756777Ab0IBWDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 18:03:38 -0400
In-Reply-To: <1283465008-18606-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes davinci architecture code that has now been rendered
useless by the previous patches in the MDIO separation series.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 arch/arm/mach-omap2/board-am3517evm.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mach-omap2/board-am3517evm.c b/arch/arm/mach-omap2/board-am3517evm.c
index 5dd1b73..5225df6 100644
--- a/arch/arm/mach-omap2/board-am3517evm.c
+++ b/arch/arm/mach-omap2/board-am3517evm.c
@@ -39,7 +39,6 @@
 
 #include "mux.h"
 
-#define AM35XX_EVM_PHY_MASK		(0xF)
 #define AM35XX_EVM_MDIO_FREQUENCY	(1000000)
 
 static struct mdio_platform_data am3517_evm_mdio_pdata = {
@@ -64,8 +63,6 @@ static struct platform_device am3517_mdio_device = {
 };
 
 static struct emac_platform_data am3517_evm_emac_pdata = {
-	.phy_mask	= AM35XX_EVM_PHY_MASK,
-	.mdio_max_freq	= AM35XX_EVM_MDIO_FREQUENCY,
 	.rmii_en	= 1,
 };
 
@@ -135,7 +132,6 @@ void am3517_evm_ethernet_init(struct emac_platform_data *pdata)
 	pdata->ctrl_reg_offset		= AM35XX_EMAC_CNTRL_OFFSET;
 	pdata->ctrl_mod_reg_offset	= AM35XX_EMAC_CNTRL_MOD_OFFSET;
 	pdata->ctrl_ram_offset		= AM35XX_EMAC_CNTRL_RAM_OFFSET;
-	pdata->mdio_reg_offset		= AM35XX_EMAC_MDIO_OFFSET;
 	pdata->ctrl_ram_size		= AM35XX_EMAC_CNTRL_RAM_SIZE;
 	pdata->version			= EMAC_VERSION_2;
 	pdata->hw_ram_addr		= AM35XX_EMAC_HW_RAM_ADDR;
-- 
1.7.0.4

