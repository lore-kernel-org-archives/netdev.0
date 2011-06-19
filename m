From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 06/11] macb: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:20:02 +0200
Message-ID: <ac8adf65aecd78e714a172a30a0b455e3a12dec9.1308481492.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab1FSLUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:18 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:17 -0700 (PDT)
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
Compile tested only.

Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/macb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 6c6a028..6944478 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -676,6 +676,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irqrestore(&bp->lock, flags);
 
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

