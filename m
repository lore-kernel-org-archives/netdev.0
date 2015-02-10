From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] i40e: Fix for stats init function call in Rx setup
Date: Mon,  9 Feb 2015 17:42:31 -0800
Message-ID: <1423532551-13843-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15783 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756329AbbBJBmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 20:42:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes indentation issue and error found in argument
reported by static analysis.  Without this patch, sparse and other
static analysis errors will be found.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f4d6d90..2206d2d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1098,7 +1098,7 @@ int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		goto err;
 
-		u64_stats_init(rx_ring->syncp);
+	u64_stats_init(&rx_ring->syncp);
 
 	/* Round up to nearest 4K */
 	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 459499a..2900438 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -596,7 +596,7 @@ int i40evf_setup_rx_descriptors(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		goto err;
 
-		u64_stats_init(rx_ring->syncp);
+	u64_stats_init(&rx_ring->syncp);
 
 	/* Round up to nearest 4K */
 	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
-- 
1.9.3
