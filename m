From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/20] sfc: Remove "XFP" from log messages that are not
	specific to XFP
Date: Thu, 29 Jan 2009 19:20:36 +0000
Message-ID: <1233256836.3656.39.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:46837 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754017AbZA2TUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:20:38 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/xfp_phy.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 2d50b6e..5d1c7f8 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -73,7 +73,7 @@ static int xfp_reset_phy(struct efx_nic *efx)
 	return rc;
 
  fail:
-	EFX_ERR(efx, "XFP: reset timed out!\n");
+	EFX_ERR(efx, "PHY reset timed out\n");
 	return rc;
 }
 
@@ -88,15 +88,15 @@ static int xfp_phy_init(struct efx_nic *efx)
 		return -ENOMEM;
 	efx->phy_data = phy_data;
 
-	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"
-		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
+	EFX_INFO(efx, "PHY ID reg %x (OUI %x model %x revision %x)\n",
+		 devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
 		 MDIO_ID_REV(devid));
 
 	phy_data->phy_mode = efx->phy_mode;
 
 	rc = xfp_reset_phy(efx);
 
-	EFX_INFO(efx, "XFP: PHY init %s.\n",
+	EFX_INFO(efx, "PHY init %s.\n",
 		 rc ? "failed" : "successful");
 	if (rc < 0)
 		goto fail;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

