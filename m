From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: Cleanup holes in flags after removing several of them
Date: Wed, 18 Jul 2012 13:31:56 -0700
Message-ID: <1342643516-2696-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18725 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755988Ab2GRUcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:05 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is just meant to defragment the flags as there are several hole
that have been introduced since several features, or the flags for them,
have been removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h |   50 +++++++++++++++---------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 4ca10e6..f7f6fe2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -433,33 +433,33 @@ struct ixgbe_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 1)
-#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 2)
-#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 3)
-#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 4)
-#define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 6)
-#define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 7)
-#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 8)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 9)
-#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 10)
-#define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 11)
-#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
-#define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
-#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 14)
-#define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
-#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
-#define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
-#define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
-#define IXGBE_FLAG_NEED_LINK_CONFIG             (u32)(1 << 23)
-#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 24)
-#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 25)
-#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 26)
-#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 27)
-#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 28)
-#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 29)
+#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 0)
+#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 1)
+#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 2)
+#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 3)
+#define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 4)
+#define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 5)
+#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 6)
+#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 7)
+#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
+#define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 9)
+#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 10)
+#define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 11)
+#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 12)
+#define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 13)
+#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 14)
+#define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 15)
+#define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 16)
+#define IXGBE_FLAG_NEED_LINK_CONFIG             (u32)(1 << 17)
+#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 18)
+#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 19)
+#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 20)
+#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 21)
+#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 22)
+#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 23)
 
 	u32 flags2;
-#define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
+#define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1 << 0)
 #define IXGBE_FLAG2_RSC_ENABLED                 (u32)(1 << 1)
 #define IXGBE_FLAG2_TEMP_SENSOR_CAPABLE         (u32)(1 << 2)
 #define IXGBE_FLAG2_TEMP_SENSOR_EVENT           (u32)(1 << 3)
-- 
1.7.10.4
