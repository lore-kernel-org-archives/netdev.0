From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 07/10] ethoc: enable transmit time stamping.
Date: Sun, 12 Jun 2011 14:19:04 +0200
Message-ID: <83e471de431f478ebc04b232ebd3aa4bf090a0c5.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Thierry Reding <thierry.reding@avionic-design.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46427 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab1FLMTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:19:30 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so3125460bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:19:30 -0700 (PDT)
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
for the OpenCores 10/100 MAC driver. Compile tested only.

Cc: Thierry Reding <thierry.reding@avionic-design.de>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/ethoc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index a83dd31..8645ec8 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -874,6 +874,7 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	spin_unlock_irq(&priv->lock);
+	skb_tx_timestamp(skb);
 out:
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
-- 
1.7.0.4

