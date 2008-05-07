From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 6/9] Fix code formatting
Date: Wed, 7 May 2008 12:58:41 +0100
Message-ID: <20080507115841.GR2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55762 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754363AbYEGL7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:59:41 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_xmac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index d99efe2..8c41662 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -32,7 +32,7 @@
 	(FALCON_XMAC_REGBANK + ((mac_reg) * FALCON_XMAC_REG_SIZE))
 
 void falcon_xmac_writel(struct efx_nic *efx,
-			efx_dword_t *value, unsigned int mac_reg)
+			 efx_dword_t *value, unsigned int mac_reg)
 {
 	efx_oword_t temp;
 
@@ -227,7 +227,7 @@ static int falcon_xgmii_status(struct efx_nic *efx)
 	/* The ISR latches, so clear it and re-read */
 	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
 	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
-	
+
 	if (EFX_DWORD_FIELD(reg, XM_LCLFLT) ||
 	    EFX_DWORD_FIELD(reg, XM_RMTFLT)) {
 		EFX_INFO(efx, "MGT_INT: "EFX_DWORD_FMT"\n", EFX_DWORD_VAL(reg));

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
