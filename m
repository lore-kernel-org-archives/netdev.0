From: Henrique Camargo <henrique.camargo@ensitec.com.br>
Subject: [PATCH] drivers: Fixes a typo from "dev" to "ndev" that caused
	compilation erros.
Date: Thu, 29 Jul 2010 12:51:49 -0300
Message-ID: <AANLkTiko540hMAUhaJr5mNKzFK2-vBOTZmEOxZWZv7ci@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: segooon@gmail.com
To: "David S. Miller" <davem@davemloft.net>,
	Chaithrika U S <chaithrika@ti.com>,
	Sriramakrishnan <srk@ti.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Jiri Pirko <jpirko@redhat.com>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60636 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab0G2Pvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 11:51:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrique Camargo

Fixes a typo from "dev" to "ndev" that caused compilation errors.

Signed-off-by: Henrique Camargo <henrique.camargo@ensitec.com.br>
---
 drivers/net/davinci_emac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 25e14d2..b89b7bf 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1182,8 +1182,8 @@ static int emac_net_tx_complete(struct emac_priv *priv,
        struct net_device *ndev = priv->ndev;
        u32 cnt;

-       if (unlikely(num_tokens && netif_queue_stopped(dev)))
-               netif_start_queue(dev);
+       if (unlikely(num_tokens && netif_queue_stopped(ndev)))
+               netif_start_queue(ndev);
        for (cnt = 0; cnt < num_tokens; cnt++) {
                struct sk_buff *skb = (struct sk_buff *)net_data_tokens[cnt];
                if (skb == NULL)
-- 
1.7.0.4
