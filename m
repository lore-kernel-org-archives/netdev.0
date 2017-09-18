From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next] net: mvpp2: remove useless goto
Date: Mon, 18 Sep 2017 15:36:51 +0200
Message-ID: <20170918133651.29556-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove a goto in the PPv2 tx function which jumps to the next line
anyway. This is a cosmetic commit.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index dd0ee2691c86..8041d692db3c 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6452,7 +6452,6 @@ static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
 		if (mvpp2_tx_frag_process(port, skb, aggr_txq, txq)) {
 			tx_desc_unmap_put(port, txq, tx_desc);
 			frags = 0;
-			goto out;
 		}
 	}
 
-- 
2.13.5
