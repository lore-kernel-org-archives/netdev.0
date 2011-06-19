From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 11/11] ucc_geth: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:20:07 +0200
Message-ID: <f1deca88c11d3efea3d669057b7ef2d4fd1d3668.1308481492.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Shlomi Gridish <gridish@freescale.com>,
	Li Yang <leoli@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464Ab1FSLUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:33 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:32 -0700 (PDT)
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308481491.git.richard.cochran@omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping.
Compile tested only.

Cc: Shlomi Gridish <gridish@freescale.com>
Cc: Li Yang <leoli@freescale.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/ucc_geth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ef04105..b091108 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3179,6 +3179,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	out_be16(uccf->p_utodr, UCC_FAST_TOD);
 #endif
 	spin_unlock_irqrestore(&ugeth->lock, flags);
+	skb_tx_timestamp(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.0.4

