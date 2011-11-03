From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 07/10] ixgbe: Fix compiler warnings
Date: Wed,  2 Nov 2011 17:19:58 -0700
Message-ID: <1320279601-1276-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9799 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414Ab1KCAUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:09 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Wrap SR-IOV specific functions in CONFIG_PCI_IOV to avoid compiler
warnings.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 5a7e1eb..4a5d889 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -42,10 +42,12 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
+#ifdef CONFIG_PCI_IOV
 void ixgbe_disable_sriov(struct ixgbe_adapter *adapter);
 void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 			const struct ixgbe_info *ii);
 int ixgbe_check_vf_assignment(struct ixgbe_adapter *adapter);
+#endif
 
 
 #endif /* _IXGBE_SRIOV_H_ */
-- 
1.7.6.4
