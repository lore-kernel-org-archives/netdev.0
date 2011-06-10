From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 10/11] stmmac: enable transmit time stamping.
Date: Fri, 10 Jun 2011 17:24:56 +0200
Message-ID: <b13147adacb1a107980242ed2d36c7bb3f5af11b.1307719258.git.richard.cochran@omicron.at>
References: <cover.1307719258.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50851 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932144Ab1FJPZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:25:33 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so2274042bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:25:32 -0700 (PDT)
In-Reply-To: <cover.1307719258.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307719258.git.richard.cochran@omicron.at>
References: <cover.1307719258.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
for the STMicroelectronics Ethernet driver. Compile tested only.

Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/stmmac/stmmac_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index e25e44a..5b85f4c 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1081,6 +1081,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

