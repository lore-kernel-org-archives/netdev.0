From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/27] sfc: Remove redundant hardware initialisation
Date: Fri, 23 Oct 2009 19:28:53 +0100
Message-ID: <1256322533.2785.7.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8503 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbZJWS2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:28:51 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c049364..57898fd 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2933,10 +2933,6 @@ int falcon_init_nic(struct efx_nic *efx)
 		falcon_write(efx, &temp, GPIO_CTL_REG_KER);
 	}
 
-	/* Set buffer table mode */
-	EFX_POPULATE_OWORD_1(temp, BUF_TBL_MODE, BUF_TBL_MODE_FULL);
-	falcon_write(efx, &temp, BUF_TBL_CFG_REG_KER);
-
 	rc = falcon_reset_sram(efx);
 	if (rc)
 		return rc;


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

