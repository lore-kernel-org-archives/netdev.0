From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/3] sfc: fix debug message format string in
 efx_farch_handle_rx_not_ok
Date: Thu, 1 Dec 2016 17:00:54 +0000
Message-ID: <2d2b245a-4849-ce9f-d1ba-f25db9e5a3b1@solarflare.com>
References: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:40018 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758319AbcLARBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:01:10 -0500
In-Reply-To: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defalconisation removed one of the string arguments, but missed the
 corresponding %s.

Fixes: 5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/farch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index c282d66..91aa3ec 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -913,7 +913,7 @@ static u16 efx_farch_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	if (rx_ev_other_err && net_ratelimit()) {
 		netif_dbg(efx, rx_err, efx->net_dev,
 			  " RX queue %d unexpected RX event "
-			  EFX_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
+			  EFX_QWORD_FMT "%s%s%s%s%s%s%s\n",
 			  efx_rx_queue_index(rx_queue), EFX_QWORD_VAL(*event),
 			  rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
 			  rx_ev_ip_hdr_chksum_err ?
