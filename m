From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/5] net: bcmgenet: add and remove missing blank lines
Date: Wed, 23 Jul 2014 10:42:13 -0700
Message-ID: <1406137335-1671-4-git-send-email-f.fainelli@gmail.com>
References: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:44734 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674AbaGWRnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:43:41 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so2113471pad.41
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:43:40 -0700 (PDT)
In-Reply-To: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl flagged two blank lines which are not needed, and one that
was missing, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0f65b4a4d4a4..25aa42b6cd34 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -619,7 +619,6 @@ static void bcmgenet_get_drvinfo(struct net_device *dev,
 	strlcpy(info->driver, "bcmgenet", sizeof(info->driver));
 	strlcpy(info->version, "v2.0", sizeof(info->version));
 	info->n_stats = BCMGENET_STATS_LEN;
-
 }
 
 static int bcmgenet_get_sset_count(struct net_device *dev, int string_set)
@@ -1268,7 +1267,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 	while ((rxpktprocessed < rxpkttoprocess) &&
 	       (rxpktprocessed < budget)) {
-
 		/* Unmap the packet contents such that we can use the
 		 * RSV from the 64 bytes descriptor when enabled and save
 		 * a 32-bits register read
@@ -1286,6 +1284,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 							   DMA_DESC_SIZE));
 		} else {
 			struct status_64 *status;
+
 			status = (struct status_64 *)skb->data;
 			dma_length_status = status->length_status;
 		}
@@ -1408,7 +1407,6 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
 		ret = bcmgenet_rx_refill(priv, cb);
 		if (ret)
 			break;
-
 	}
 
 	return ret;
-- 
1.9.1
