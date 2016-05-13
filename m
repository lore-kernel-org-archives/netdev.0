From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] igbvf: remove unused variable and dead code
Date: Fri, 13 May 2016 16:43:50 -0700
Message-ID: <1463183035-31888-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49411 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211AbcEMXoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:44:01 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The variable rdlen is set but never used, and thus setting it is dead
code. Remove it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index c124422..78af4c7 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1367,7 +1367,7 @@ static void igbvf_configure_rx(struct igbvf_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct igbvf_ring *rx_ring = adapter->rx_ring;
 	u64 rdba;
-	u32 rdlen, rxdctl;
+	u32 rxdctl;
 
 	/* disable receives */
 	rxdctl = er32(RXDCTL(0));
@@ -1375,8 +1375,6 @@ static void igbvf_configure_rx(struct igbvf_adapter *adapter)
 	e1e_flush();
 	msleep(10);
 
-	rdlen = rx_ring->count * sizeof(union e1000_adv_rx_desc);
-
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
-- 
2.5.5
