From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4] mv643xx_eth: enable transmit time stamping.
Date: Tue, 21 Jun 2011 06:35:19 +0200
Message-ID: <20110621043519.GA3579@riccoc20.at.omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
 <96e6a2899b55ac1272cee8ce63e2549e24a10386.1308556146.git.richard.cochran@omicron.at>
 <20110620163524.GD994@wantstofly.org>
 <20110620.135512.26659219089505445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46653 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab1FUEfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 00:35:14 -0400
Received: by fxm17 with SMTP id 17so1401804fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 21:35:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110620.135512.26659219089505445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch enables software (and phy device) transmit time stamping.
Compile tested only.

Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/mv643xx_eth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1b7d2c1..77dc6ab 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -840,6 +840,8 @@ no_csum:
 
 	__skb_queue_tail(&txq->tx_skb, skb);
 
+	skb_tx_timestamp(skb);
+
 	/* ensure all other descriptors are written before first cmd_sts */
 	wmb();
 	desc->cmd_sts = cmd_sts;
-- 
1.7.0.4

