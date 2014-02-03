From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 05/13] sfc: Rename 'use_options' variable in tso_start()
 to clearer 'use_opt_desc'
Date: Mon, 3 Feb 2014 23:34:35 +0000
Message-ID: <52F0278B.8060100@solarflare.com>
References: <52F02469.50302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8174 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbaBCXei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:34:38 -0500
In-Reply-To: <52F02469.50302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index aadeb61..5f9b553 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -1000,7 +1000,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 static int tso_start(struct tso_state *st, struct efx_nic *efx,
 		     const struct sk_buff *skb)
 {
-	bool use_options = efx_nic_rev(efx) >= EFX_REV_HUNT_A0;
+	bool use_opt_desc = efx_nic_rev(efx) >= EFX_REV_HUNT_A0;
 	struct device *dma_dev = &efx->pci_dev->dev;
 	unsigned int header_len, in_len;
 	dma_addr_t dma_addr;
@@ -1026,7 +1026,7 @@ static int tso_start(struct tso_state *st, struct efx_nic *efx,
 
 	st->out_len = skb->len - header_len;
 
-	if (!use_options) {
+	if (!use_opt_desc) {
 		st->header_unmap_len = 0;
 
 		if (likely(in_len == 0)) {
