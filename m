From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 05/13] sfc: Rename 'use_options' variable in tso_start()
 to clearer 'use_opt_desc'
Date: Wed, 12 Feb 2014 18:59:41 +0000
Message-ID: <52FBC49D.5040802@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50962 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753983AbaBLS7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:59:46 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3aa22cd..fa94753 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -1002,7 +1002,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 static int tso_start(struct tso_state *st, struct efx_nic *efx,
 		     const struct sk_buff *skb)
 {
-	bool use_options = efx_nic_rev(efx) >= EFX_REV_HUNT_A0;
+	bool use_opt_desc = efx_nic_rev(efx) >= EFX_REV_HUNT_A0;
 	struct device *dma_dev = &efx->pci_dev->dev;
 	unsigned int header_len, in_len;
 	dma_addr_t dma_addr;
@@ -1028,7 +1028,7 @@ static int tso_start(struct tso_state *st, struct efx_nic *efx,
 
 	st->out_len = skb->len - header_len;
 
-	if (!use_options) {
+	if (!use_opt_desc) {
 		st->header_unmap_len = 0;
 
 		if (likely(in_len == 0)) {
