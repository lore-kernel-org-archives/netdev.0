From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: remove duplicate assignment
Date: Fri, 26 Aug 2016 15:12:57 +0100
Message-ID: <4b36347b-c8d7-9862-75c3-8eac23d664cc@solarflare.com>
References: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:4458 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751758AbcHZOT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 10:19:58 -0400
In-Reply-To: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nic_data was already initialised to the right thing, no need to assign
it again.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index d039f29..c4cd6b0 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1715,7 +1715,6 @@ static int efx_ef10_try_update_nic_stats_pf(struct efx_nic *efx)
 	efx_ef10_get_stat_mask(efx, mask);
 
 	dma_stats = efx->stats_buffer.addr;
-	nic_data = efx->nic_data;
 
 	generation_end = dma_stats[MC_CMD_MAC_GENERATION_END];
 	if (generation_end == EFX_MC_STATS_GENERATION_INVALID)
