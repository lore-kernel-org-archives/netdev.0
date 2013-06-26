From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: Fix typo
Date: Wed, 26 Jun 2013 03:55:15 -0700
Message-ID: <1372244122-17664-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12049 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab3FZKz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:27 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Fix a typo where the code should use a bitwise "and" rather than a logical
"and".

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 6369fb9..73c8e73 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -820,7 +820,7 @@ static int ixgbe_set_vf_vlan_msg(struct ixgbe_adapter *adapter,
 		 * is cleared if the PF only added itself to the pool
 		 * because the PF is in promiscuous mode.
 		 */
-		if ((vlvf && VLAN_VID_MASK) == vid &&
+		if ((vlvf & VLAN_VID_MASK) == vid &&
 		    !test_bit(vid, adapter->active_vlans) && !bits)
 			ixgbe_set_vf_vlan(adapter, add, vid, VMDQ_P(0));
 	}
-- 
1.7.11.7
