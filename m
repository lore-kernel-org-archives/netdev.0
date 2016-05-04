From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] ixgbevf: Add the device ID's presented while running on Hyper-V
Date: Wed,  4 May 2016 09:26:38 -0700
Message-ID: <1462379208-3997-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: KY Srinivasan <kys@microsoft.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:64255 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754377AbcEDQ0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:26:53 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KY Srinivasan <kys@microsoft.com>

Intel SR-IOV cards present different ID when running on Hyper-V.
Add the device IDs presented while running on Hyper-V.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 74901f7..ae09d60 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -33,6 +33,11 @@
 #define IXGBE_DEV_ID_X550_VF		0x1565
 #define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
 
+#define IXGBE_DEV_ID_82599_VF_HV	0x152E
+#define IXGBE_DEV_ID_X540_VF_HV		0x1530
+#define IXGBE_DEV_ID_X550_VF_HV		0x1564
+#define IXGBE_DEV_ID_X550EM_X_VF_HV	0x15A9
+
 #define IXGBE_VF_IRQ_CLEAR_MASK		7
 #define IXGBE_VF_MAX_TX_QUEUES		8
 #define IXGBE_VF_MAX_RX_QUEUES		8
-- 
2.5.5
