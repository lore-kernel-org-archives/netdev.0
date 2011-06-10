From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 08/10] r6040: enable transmit time stamping.
Date: Fri, 10 Jun 2011 17:07:06 +0200
Message-ID: <9e20aff5aefa9629b5dd54e82d86cdf4a4baaca1.1307717675.git.richard.cochran@omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57323 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482Ab1FJPHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:07:42 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so2260711bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:07:42 -0700 (PDT)
In-Reply-To: <cover.1307717675.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307717675.git.richard.cochran@omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
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

