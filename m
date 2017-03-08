From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/9] nfp: reorder variables in nfp_net_tx()
Date: Wed,  8 Mar 2017 08:57:04 -0800
Message-ID: <20170308165708.96087-6-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32921 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753637AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pf0-f182.google.com with SMTP id w189so16980033pfb.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:12 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorder variables longest to shortest to comply with netdev coding style.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 0be47188fd36..8b5fa6fe8807 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -739,10 +739,10 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	const struct skb_frag_struct *frag;
-	struct nfp_net_r_vector *r_vec;
 	struct nfp_net_tx_desc *txd, txdg;
-	struct nfp_net_tx_buf *txbuf;
 	struct nfp_net_tx_ring *tx_ring;
+	struct nfp_net_r_vector *r_vec;
+	struct nfp_net_tx_buf *txbuf;
 	struct netdev_queue *nd_q;
 	dma_addr_t dma_addr;
 	unsigned int fsize;
-- 
2.11.0
