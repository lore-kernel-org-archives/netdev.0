From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: remove RESET_TYPE_RX_RECOVERY
Date: Thu, 1 Dec 2016 17:01:19 +0000
Message-ID: <dc5d7d63-40af-37bc-aadd-ea7e5fa06a86@solarflare.com>
References: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:11015 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932671AbcLARBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:01:34 -0500
In-Reply-To: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's no longer used now that Falcon is gone.

Also remove a reference in a comment to an ioctl that doesn't exist.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c  | 1 -
 drivers/net/ethernet/sfc/enum.h | 5 +----
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4a234a8..da7028d 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -82,7 +82,6 @@ const char *const efx_reset_type_names[] = {
 	[RESET_TYPE_DISABLE]            = "DISABLE",
 	[RESET_TYPE_TX_WATCHDOG]        = "TX_WATCHDOG",
 	[RESET_TYPE_INT_ERROR]          = "INT_ERROR",
-	[RESET_TYPE_RX_RECOVERY]        = "RX_RECOVERY",
 	[RESET_TYPE_DMA_ERROR]          = "DMA_ERROR",
 	[RESET_TYPE_TX_SKIP]            = "TX_SKIP",
 	[RESET_TYPE_MC_FAILURE]         = "MC_FAILURE",
diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
index c94f562..6fa8242 100644
--- a/drivers/net/ethernet/sfc/enum.h
+++ b/drivers/net/ethernet/sfc/enum.h
@@ -148,7 +148,6 @@ enum efx_loopback_mode {
  * @RESET_TYPE_DISABLE: Reset datapath, MAC and PHY; leave NIC disabled
  * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
  * @RESET_TYPE_INT_ERROR: reset due to internal error
- * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
  * @RESET_TYPE_DMA_ERROR: DMA error
  * @RESET_TYPE_TX_SKIP: hardware completed empty tx descriptors
  * @RESET_TYPE_MC_FAILURE: MC reboot/assertion
@@ -166,15 +165,13 @@ enum reset_type {
 	RESET_TYPE_MAX_METHOD,
 	RESET_TYPE_TX_WATCHDOG,
 	RESET_TYPE_INT_ERROR,
-	RESET_TYPE_RX_RECOVERY,
 	RESET_TYPE_DMA_ERROR,
 	RESET_TYPE_TX_SKIP,
 	RESET_TYPE_MC_FAILURE,
 	/* RESET_TYPE_MCDI_TIMEOUT is actually a method, not just a reason, but
 	 * it doesn't fit the scope hierarchy (not well-ordered by inclusion).
 	 * We encode this by having its enum value be greater than
-	 * RESET_TYPE_MAX_METHOD. This also prevents issuing it with
-	 * efx_ioctl_reset.
+	 * RESET_TYPE_MAX_METHOD.
 	 */
 	RESET_TYPE_MCDI_TIMEOUT,
 	RESET_TYPE_MAX,
