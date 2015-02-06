From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/16] ixgbe: allow multiple queues in SRIOV mode
Date: Thu,  5 Feb 2015 20:31:13 -0800
Message-ID: <1423197085-32270-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	kernel-team@fb.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31696 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595AbbBFEbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 23:31:38 -0500
In-Reply-To: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

ixgbe_set_sriov_queues() has the logic to allow multiple queues, this patch
just removes the limitation.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c76ba90..a82a36b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -101,9 +101,6 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 			adapter->dcb_cfg.num_tcs.pfc_tcs = 1;
 		}
 
-		/* We do not support RSS w/ SR-IOV */
-		adapter->ring_feature[RING_F_RSS].limit = 1;
-
 		/* Disable RSC when in SR-IOV mode */
 		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
 				     IXGBE_FLAG2_RSC_ENABLED);
-- 
1.9.3
