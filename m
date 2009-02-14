From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 09/43] drivers/net/r6040.c: fix sparse warning: Using plain
	integer as NULL pointer
Date: Sat, 14 Feb 2009 22:14:04 +0100
Message-ID: <20090214211400.23489.24726.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:52585 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbZBNVOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:14:20 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/net/r6040.c:487:31: warning: Using plain integer as NULL pointer
  drivers/net/r6040.c:492:31: warning: Using plain integer as NULL pointer

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/r6040.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 3c27a7b..9c95ebe 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -484,12 +484,12 @@ static int r6040_close(struct net_device *dev)
 	/* Free Descriptor memory */
 	if (lp->rx_ring) {
 		pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
-		lp->rx_ring = 0;
+		lp->rx_ring = NULL;
 	}
 
 	if (lp->tx_ring) {
 		pci_free_consistent(pdev, TX_DESC_SIZE, lp->tx_ring, lp->tx_ring_dma);
-		lp->tx_ring = 0;
+		lp->tx_ring = NULL;
 	}
 
 	return 0;

