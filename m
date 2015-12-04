From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] fm10k: TRIVIAL cleanup order at top of fm10k_xmit_frame
Date: Thu,  3 Dec 2015 16:29:54 -0800
Message-ID: <1449188994-64940-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5708 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430AbbLDAaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:30:00 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c72c805..7114bea 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1098,11 +1098,11 @@ dma_error:
 netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring)
 {
+	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 	struct fm10k_tx_buffer *first;
-	int tso;
-	u32 tx_flags = 0;
 	unsigned short f;
-	u16 count = TXD_USE_COUNT(skb_headlen(skb));
+	u32 tx_flags = 0;
+	int tso;
 
 	/* need: 1 descriptor per page * PAGE_SIZE/FM10K_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_headlen/FM10K_MAX_DATA_PER_TXD,
-- 
2.5.0
