From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] e1000e: prevent warning from -Wunused-parameter
Date: Tue, 21 May 2013 15:03:10 -0700
Message-ID: <1369173800-20326-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30025 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747Ab3EUWD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:26 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ad5f434..77f81cb 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2673,7 +2673,7 @@ static int e1000e_poll(struct napi_struct *napi, int weight)
 }
 
 static int e1000_vlan_rx_add_vid(struct net_device *netdev,
-				 __be16 proto, u16 vid)
+				 __always_unused __be16 proto, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -2699,7 +2699,7 @@ static int e1000_vlan_rx_add_vid(struct net_device *netdev,
 }
 
 static int e1000_vlan_rx_kill_vid(struct net_device *netdev,
-				  __be16 proto, u16 vid)
+				  __always_unused __be16 proto, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-- 
1.7.11.7
