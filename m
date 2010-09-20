From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 6/8] sfc: Include RX IP filter table in
 register dump
Date: Mon, 20 Sep 2010 19:43:53 +0100
Message-ID: <1285008233.2282.109.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7270 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab0ITSn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:43:56 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For backward compatibility, add it at the end.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 6c5c0ce..c4de001 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1849,8 +1849,7 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	REGISTER_TABLE_BB_CZ(TX_DESC_PTR_TBL),
 	REGISTER_TABLE_AA(EVQ_PTR_TBL_KER),
 	REGISTER_TABLE_BB_CZ(EVQ_PTR_TBL),
-	/* The register buffer is allocated with slab, so we can't
-	 * reasonably read all of the buffer table (up to 8MB!).
+	/* We can't reasonably read all of the buffer table (up to 8MB!).
 	 * However this driver will only use a few entries.  Reading
 	 * 1K entries allows for some expansion of queue count and
 	 * size before we need to change the version. */
@@ -1858,7 +1857,6 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 				  A, A, 8, 1024),
 	REGISTER_TABLE_DIMENSIONS(BUF_FULL_TBL, FR_BZ_BUF_FULL_TBL,
 				  B, Z, 8, 1024),
-	/* RX_FILTER_TBL{0,1} is huge and not used by this driver */
 	REGISTER_TABLE_CZ(RX_MAC_FILTER_TBL0),
 	REGISTER_TABLE_BB_CZ(TIMER_TBL),
 	REGISTER_TABLE_BB_CZ(TX_PACE_TBL),
@@ -1868,6 +1866,7 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	REGISTER_TABLE_CZ(MC_TREG_SMEM),
 	/* MSIX_PBA_TABLE is not mapped */
 	/* SRM_DBG is not mapped (and is redundant with BUF_FLL_TBL) */
+	REGISTER_TABLE_BZ(RX_FILTER_TBL0),
 };
 
 size_t efx_nic_get_regs_len(struct efx_nic *efx)
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

