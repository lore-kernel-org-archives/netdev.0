From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: atl1c: fix spelling mistake: "droppted" -> "dropped"
Date: Tue, 27 Jun 2017 10:51:22 +0100
Message-ID: <20170627095122.15699-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>,
        Chris Snook <chris.snook@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33235 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751504AbdF0Jv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 05:51:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in netif_info message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 7e913d8331c3..8c9986f3fc01 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2252,7 +2252,7 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 
 	if (atl1c_tx_map(adapter, skb, tpd, type) < 0) {
 		netif_info(adapter, tx_done, adapter->netdev,
-			   "tx-skb droppted due to dma error\n");
+			   "tx-skb dropped due to dma error\n");
 		/* roll back tpd/buffer */
 		atl1c_tx_rollback(adapter, tpd, type);
 		dev_kfree_skb_any(skb);
-- 
2.11.0
