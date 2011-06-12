From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 08/10] r6040: enable transmit time stamping.
Date: Sun, 12 Jun 2011 14:19:05 +0200
Message-ID: <fcecd68a8e444901da041e60b70de782c6a96849.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46427 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab1FLMTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:19:33 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so3125460bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:19:33 -0700 (PDT)
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
for the RDC R6040 Fast Ethernet MAC. Compile tested only.

Cc: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/r6040.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 200a363..5ee5f8f 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -846,6 +846,8 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

