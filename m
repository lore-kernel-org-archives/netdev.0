From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/52] sfc: Reverse the XOFF/XON pause frame control fifo thresholds
Date: Mon, 1 Sep 2008 12:46:21 +0100
Message-ID: <20080901114620.GD7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35386 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755783AbYIALqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:23 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were clearly bogus.

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index f575322..8ee63da 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2585,8 +2585,8 @@ int falcon_init_nic(struct efx_nic *efx)
 		  rx_xoff_thresh_bytes : efx->type->rx_xoff_thresh);
 	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_MAC_TH, thresh / 256);
 	/* RX control FIFO thresholds [32 entries] */
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XON_TX_TH, 25);
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_TX_TH, 20);
+	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XON_TX_TH, 20);
+	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_TX_TH, 25);
 	falcon_write(efx, &temp, RX_CFG_REG_KER);
 
 	/* Set destination of both TX and RX Flush events */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

