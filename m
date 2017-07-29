From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 5/6] net: moxa: Fix for typo in comment to function moxart_mac_setup_desc_ring()
Date: Sat, 29 Jul 2017 18:42:38 +0800
Message-ID: <20170729104239.14999-6-sz.lin@moxa.com>
References: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729104239.14999-1-sz.lin@moxa.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: SZ Lin <sz.lin@moxa.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 31e179a651ae..2e4effa9fe45 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -161,7 +161,7 @@ static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 
 	priv->rx_head = 0;
 
-	/* reset the MAC controller TX/RX desciptor base address */
+	/* reset the MAC controller TX/RX descriptor base address */
 	writel(priv->tx_base, priv->base + REG_TXR_BASE_ADDRESS);
 	writel(priv->rx_base, priv->base + REG_RXR_BASE_ADDRESS);
 }
-- 
2.13.3
