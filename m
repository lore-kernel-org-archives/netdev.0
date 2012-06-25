From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH fix] mac802154: add missed braces
Date: Mon, 25 Jun 2012 17:30:13 +0400
Message-ID: <1340631013-27556-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49416 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab2FYNd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:33:27 -0400
Received: by bkcji2 with SMTP id ji2so3128610bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 06:33:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missed braces after 'if' operator.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/tx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 8781d8f9..434b687 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -83,9 +83,10 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 {
 	struct xmit_work *work;
 
-	if (!(priv->phy->channels_supported[page] & (1 << chan)))
+	if (!(priv->phy->channels_supported[page] & (1 << chan))) {
 		WARN_ON(1);
 		return NETDEV_TX_OK;
+	}
 
 	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
 		u16 crc = crc_ccitt(0, skb->data, skb->len);
-- 
1.7.2.3
