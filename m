From: <dinguyen@altera.com>
Subject: [PATCH] net: ethernet: stmicro: stmmac: Fix compile error when STMMAC_XMIT_DEBUG used
Date: Wed, 12 Jun 2013 11:05:03 -0500
Message-ID: <1371053103-13536-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, Dinh Nguyen <dinguyen@altera.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0185.outbound.messaging.microsoft.com ([213.199.154.185]:33323
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751464Ab3FLQFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 12:05:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function:
stmmac_xmit drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1902:74:
error: expected ) before __func__

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 618446a..ee919ca 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1899,7 +1899,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef STMMAC_XMIT_DEBUG
 	if (netif_msg_pktdata(priv)) {
-		pr_info("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d"
+		pr_info("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
 			__func__, (priv->cur_tx % txsize),
 			(priv->dirty_tx % txsize), entry, first, nfrags);
 		if (priv->extend_desc)
-- 
1.7.9.5
