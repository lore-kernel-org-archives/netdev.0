From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/6] [NET-NEXT]qlge: Remove some unused structure elements.
Date: Sat, 11 Oct 2008 10:17:12 -0700
Message-ID: <1223745433-26440-5-git-send-email-ron.mercer@qlogic.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13301 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760557AbYJKRRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:17:17 -0400
In-Reply-To: <20081011171614.GA26384@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |    5 -----
 drivers/net/qlge/qlge_dbg.c |    4 ----
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index d0454db..42fd24a 100755
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1399,8 +1399,6 @@ struct ql_adapter {
 	struct msix_entry *msi_x_entry;
 	struct intr_context intr_context[MAX_RX_RINGS];
 
-	int (*legacy_check) (struct ql_adapter *);
-
 	int tx_ring_count;	/* One per online CPU. */
 	u32 rss_ring_first_cq_id;/* index of first inbound (rss) rx_ring */
 	u32 rss_ring_count;	/* One per online CPU.  */
@@ -1411,11 +1409,8 @@ struct ql_adapter {
 	 *  (CPU count * inbound (RSS) completion rx_ring)
 	 */
 	int rx_ring_count;
-	int ring_mem_size;
-	void *ring_mem;
 	struct rx_ring rx_ring[MAX_RX_RINGS];
 	struct tx_ring tx_ring[MAX_TX_RINGS];
-	u32 default_rx_queue;
 	int rx_csum;
 
 	u16 rx_coalesce_usecs;	/* cqicb->int_delay */
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 47df304..5e24e50 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -404,8 +404,6 @@ void ql_dump_qdev(struct ql_adapter *qdev)
 	}
 	printk(KERN_ERR PFX "qdev->tx_ring_count = %d.\n", qdev->tx_ring_count);
 	printk(KERN_ERR PFX "qdev->rx_ring_count = %d.\n", qdev->rx_ring_count);
-	printk(KERN_ERR PFX "qdev->ring_mem_size = %d.\n", qdev->ring_mem_size);
-	printk(KERN_ERR PFX "qdev->ring_mem 	= %p.\n", qdev->ring_mem);
 	printk(KERN_ERR PFX "qdev->intr_count 	= %d.\n", qdev->intr_count);
 	printk(KERN_ERR PFX "qdev->tx_ring		= %p.\n",
 	       qdev->tx_ring);
@@ -414,8 +412,6 @@ void ql_dump_qdev(struct ql_adapter *qdev)
 	printk(KERN_ERR PFX "qdev->rss_ring_count 	= %d.\n",
 	       qdev->rss_ring_count);
 	printk(KERN_ERR PFX "qdev->rx_ring	= %p.\n", qdev->rx_ring);
-	printk(KERN_ERR PFX "qdev->default_rx_queue	= %d.\n",
-	       qdev->default_rx_queue);
 	printk(KERN_ERR PFX "qdev->xg_sem_mask		= 0x%08x.\n",
 	       qdev->xg_sem_mask);
 	printk(KERN_ERR PFX "qdev->port_link_up		= 0x%08x.\n",
-- 
1.6.0

