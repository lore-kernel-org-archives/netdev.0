From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 2/6] net: moxa: Prefer 'unsigned int' to bare use of 'unsigned'
Date: Sat, 29 Jul 2017 18:42:35 +0800
Message-ID: <20170729104239.14999-3-sz.lin@moxa.com>
References: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729104239.14999-1-sz.lin@moxa.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use 'unsigned int' instead of 'unsigned'
This warning is found using checkpatch.pl

Signed-off-by: SZ Lin <sz.lin@moxa.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 105215862949..9997e72103d5 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -288,8 +288,8 @@ static int moxart_tx_queue_space(struct net_device *ndev)
 static void moxart_tx_finished(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
-	unsigned tx_head = priv->tx_head;
-	unsigned tx_tail = priv->tx_tail;
+	unsigned int tx_head = priv->tx_head;
+	unsigned int tx_tail = priv->tx_tail;
 
 	while (tx_tail != tx_head) {
 		dma_unmap_single(&ndev->dev, priv->tx_mapping[tx_tail],
-- 
2.13.3
