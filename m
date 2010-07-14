From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 06/11] tulip: formatting of pointers in printk()
Date: Wed, 14 Jul 2010 22:03:25 +0400
Message-ID: <1279130606-10927-1-git-send-email-segooon@gmail.com>
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36979 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191Ab0GNSD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 14:03:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use %p instead of %08x in printk().

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/tulip/winbond-840.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 608b279..66d41cf 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1514,12 +1514,12 @@ static int netdev_close(struct net_device *dev)
 	if (debug > 2) {
 		int i;
 
-		printk(KERN_DEBUG"  Tx ring at %08x:\n", (int)np->tx_ring);
+		printk(KERN_DEBUG"  Tx ring at %p:\n", np->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
 			printk(KERN_DEBUG " #%d desc. %04x %04x %08x\n",
 			       i, np->tx_ring[i].length,
 			       np->tx_ring[i].status, np->tx_ring[i].buffer1);
-		printk(KERN_DEBUG "  Rx ring %08x:\n", (int)np->rx_ring);
+		printk(KERN_DEBUG "  Rx ring %p:\n", np->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			printk(KERN_DEBUG " #%d desc. %04x %04x %08x\n",
 			       i, np->rx_ring[i].length,
-- 
1.7.0.4

