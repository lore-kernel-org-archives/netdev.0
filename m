From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] mwifiex: illegal assignment
Date: Wed, 18 May 2016 01:01:58 +0200
Message-ID: <1463526118-11822-1-git-send-email-xypron.glpk@gmx.de>
Cc: Xinming Hu <huxm@marvell.com>, Cathy Luo <cluo@marvell.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:52214 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbcEQXCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 19:02:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Variable adapter is incorrectly initialized.

Fixes: bf00dc22bc7a ("mwifiex: AMSDU Rx frame handling in AP mode")
Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/uap_txrx.c b/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
index 666e91a..bf5660e 100644
--- a/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
+++ b/drivers/net/wireless/marvell/mwifiex/uap_txrx.c
@@ -272,7 +272,7 @@ int mwifiex_handle_uap_rx_forward(struct mwifiex_private *priv,
 int mwifiex_uap_recv_packet(struct mwifiex_private *priv,
 			    struct sk_buff *skb)
 {
-	struct mwifiex_adapter *adapter = adapter;
+	struct mwifiex_adapter *adapter = priv->adapter;
 	struct mwifiex_sta_node *src_node;
 	struct ethhdr *p_ethhdr;
 	struct sk_buff *skb_uap;
-- 
2.1.4
