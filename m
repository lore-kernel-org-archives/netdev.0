From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e1000e: Cleanup unecessary references
Date: Sat,  8 Mar 2014 01:25:28 -0800
Message-ID: <1394270741-29926-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39895 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbaCHJZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:45 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Cleaning up some pointer references that are no longer necessary

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e6f8961d..1f144e9 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1701,7 +1701,7 @@ static void e1000_clean_rx_ring(struct e1000_ring *rx_ring)
 	adapter->flags2 &= ~FLAG2_IS_DISCARDING;
 
 	writel(0, rx_ring->head);
-	if (rx_ring->adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
 		e1000e_update_rdt_wa(rx_ring, 0);
 	else
 		writel(0, rx_ring->tail);
@@ -2405,7 +2405,7 @@ static void e1000_clean_tx_ring(struct e1000_ring *tx_ring)
 	tx_ring->next_to_clean = 0;
 
 	writel(0, tx_ring->head);
-	if (tx_ring->adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
 		e1000e_update_tdt_wa(tx_ring, 0);
 	else
 		writel(0, tx_ring->tail);
-- 
1.8.3.1
