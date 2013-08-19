From: Sanil Kumar D <skd.linux@gmail.com>
Subject: [PATCH] drivers:net:ifb: Fixed coding style error:assignment in if statement
Date: Tue, 20 Aug 2013 05:09:37 +0530
Message-ID: <1376955577-26518-1-git-send-email-skd.linux@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sanil Kumar D <skd.linux@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed coding style error (assignment within if statement at 2 places in drivers/net/ifb.c)

Signed-off-by: Sanil Kumar D <skd.linux@gmail.com>
---
 drivers/net/ifb.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index a3bed28..f3fa85a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -68,7 +68,8 @@ static void ri_tasklet(unsigned long dev)
 	struct sk_buff *skb;
 
 	txq = netdev_get_tx_queue(_dev, 0);
-	if ((skb = skb_peek(&dp->tq)) == NULL) {
+	skb = skb_peek(&dp->tq);
+	if (skb == NULL) {
 		if (__netif_tx_trylock(txq)) {
 			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
 			__netif_tx_unlock(txq);
@@ -112,7 +113,8 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	if (__netif_tx_trylock(txq)) {
-		if ((skb = skb_peek(&dp->rq)) == NULL) {
+		skb = skb_peek(&dp->rq);
+		if (skb == NULL) {
 			dp->tasklet_pending = 0;
 			if (netif_queue_stopped(_dev))
 				netif_wake_queue(_dev);
-- 
1.7.9.5
