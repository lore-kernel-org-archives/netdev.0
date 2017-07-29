From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 4/6] net: moxa: Remove extra space after a cast
Date: Sat, 29 Jul 2017 18:42:37 +0800
Message-ID: <20170729104239.14999-5-sz.lin@moxa.com>
References: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34686 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753781AbdG2Kn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 06:43:58 -0400
In-Reply-To: <20170729104239.14999-1-sz.lin@moxa.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No space is necessary after a cast
This warning is found using checkpatch.pl

Signed-off-by: SZ Lin <sz.lin@moxa.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 1d6384873393..31e179a651ae 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -311,7 +311,7 @@ static void moxart_tx_finished(struct net_device *ndev)
 
 static irqreturn_t moxart_mac_interrupt(int irq, void *dev_id)
 {
-	struct net_device *ndev = (struct net_device *) dev_id;
+	struct net_device *ndev = (struct net_device *)dev_id;
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
 	unsigned int ists = readl(priv->base + REG_INTERRUPT_STATUS);
 
-- 
2.13.3
