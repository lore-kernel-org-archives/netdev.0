From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 16/23] igb: cleanup igb.h header whitespace and
	some structure formatting
Date: Wed, 28 Oct 2009 02:50:38 -0700
Message-ID: <20091028095037.13156.52084.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:36277
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752196AbZJ1JyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:54:22 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the layout of the ring and adapter structs to fill a few
holes in the structure.  It also cleans up some whitespace and formatting
issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index b9fcfd3..3298f5a 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -185,16 +185,15 @@ struct igb_ring {
 	dma_addr_t dma;                /* phys address of the ring */
 	void *desc;                    /* descriptor ring memory */
 	unsigned int size;             /* length of desc. ring in bytes */
-	unsigned int count;            /* number of desc. in the ring */
+	u16 count;                     /* number of desc. in the ring */
 	u16 next_to_use;
 	u16 next_to_clean;
+	u8 queue_index;
+	u8 reg_idx;
 	void __iomem *head;
 	void __iomem *tail;
 	struct igb_buffer *buffer_info; /* array of buffer info structs */
 
-	u8 queue_index;
-	u8 reg_idx;
-
 	unsigned int total_bytes;
 	unsigned int total_packets;
 
@@ -249,6 +248,7 @@ struct igb_adapter {
 	u32 en_mng_pt;
 	u16 link_speed;
 	u16 link_duplex;
+
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
@@ -311,8 +311,8 @@ struct igb_adapter {
 	u32 eeprom_wol;
 
 	struct igb_ring *multi_tx_table[IGB_ABS_MAX_TX_QUEUES];
-	unsigned int tx_ring_count;
-	unsigned int rx_ring_count;
+	u16 tx_ring_count;
+	u16 rx_ring_count;
 	unsigned int vfs_allocated_count;
 	struct vf_data_storage *vf_data;
 };

