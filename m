From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/4] r6040: compile error
Date: Wed, 28 Nov 2007 23:09:16 +0100
Message-ID: <20071128220916.GA19096@electric-eye.fr.zoreil.com>
References: <20071127204536.61bf7921.akpm@google.com> <20071127230601.fbb60024.akpm@linux-foundation.org> <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37348 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756944AbXK1WNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 17:13:14 -0500
Content-Disposition: inline
In-Reply-To: <20071128220812.GA12598@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/r6040.c: In function 'rx_buf_alloc':
drivers/net/r6040.c:262: warning: passing argument 2 of 'pci_map_single' makes pointer from integer without a cast

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 1d7efa2..6a6329e 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -260,7 +260,7 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 		if (!descptr->skb_ptr)
 			break;
 		descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
-			descptr->skb_ptr->tail,
+			descptr->skb_ptr->data,
 			MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
 		descptr->status = 0x8000;
 		descptr = descptr->vndescp;
-- 
1.5.3.3

