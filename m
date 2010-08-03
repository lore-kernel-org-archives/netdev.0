From: Henrique Camargo <henrique.camargo@ensitec.com.br>
Subject: [PATCH] Fixes a typo from "dev" to "ndev"
Date: Tue, 03 Aug 2010 00:10:42 -0300
Message-ID: <1280805042.2089.6.camel@lemming>
References: <AANLkTiko540hMAUhaJr5mNKzFK2-vBOTZmEOxZWZv7ci@mail.gmail.com>
	 <20100730.222034.183058824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chaithrika@ti.com, srk@ti.com, khilman@deeprootsystems.com,
	jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, segooon@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100730.222034.183058824.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The typo was causing compilation errors since "dev" was not defined.

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
 
-	if (unlikely(num_tokens && netif_queue_stopped(dev)))
-		netif_start_queue(dev);
+	if (unlikely(num_tokens && netif_queue_stopped(ndev)))
+		netif_start_queue(ndev);
 	for (cnt = 0; cnt < num_tokens; cnt++) {
 		struct sk_buff *skb = (struct sk_buff *)net_data_tokens[cnt];
 		if (skb == NULL)
-- 
1.7.0.4
