From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] fm10k: use BIT() macro instead of open-coded bit-shifting
Date: Sun, 13 Dec 2015 16:27:44 -0800
Message-ID: <1450052867-36654-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:65123 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063AbbLNA1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:52 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h      | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 02219d9..849e36d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -419,7 +419,7 @@ static inline u16 fm10k_desc_unused(struct fm10k_ring *ring)
 	 (&(((union fm10k_rx_desc *)((R)->desc))[i]))
 
 #define FM10K_MAX_TXD_PWR	14
-#define FM10K_MAX_DATA_PER_TXD	(1 << FM10K_MAX_TXD_PWR)
+#define FM10K_MAX_DATA_PER_TXD	BIT(FM10K_MAX_TXD_PWR)
 
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S)	DIV_ROUND_UP((S), FM10K_MAX_DATA_PER_TXD)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 2fd962f..098883d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -354,7 +354,7 @@ struct fm10k_hw;
 #define FM10K_VLAN_TABLE_VID_MAX		4096
 #define FM10K_VLAN_TABLE_VSI_MAX		64
 #define FM10K_VLAN_LENGTH_SHIFT			16
-#define FM10K_VLAN_CLEAR			(1 << 15)
+#define FM10K_VLAN_CLEAR			BIT(15)
 #define FM10K_VLAN_ALL \
 	((FM10K_VLAN_TABLE_VID_MAX - 1) << FM10K_VLAN_LENGTH_SHIFT)
 
-- 
2.5.0
