From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/13] i40e/i40evf: remove unused RX_LRO define
Date: Thu,  5 Jun 2014 03:12:52 -0700
Message-ID: <1401963181-11110-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19636 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826AbaFEKNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 06:13:06 -0400
In-Reply-To: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Remove unused defines and macros for RX_LRO.

Change-ID: I8ca6715edfa62b56837417a1c4ff68c2345dab6e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 7 -------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 7 -------
 2 files changed, 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index d5e3f54..30e5fe3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -179,7 +179,6 @@ enum i40e_ring_state_t {
 	__I40E_TX_DETECT_HANG,
 	__I40E_HANG_CHECK_ARMED,
 	__I40E_RX_PS_ENABLED,
-	__I40E_RX_LRO_ENABLED,
 	__I40E_RX_16BYTE_DESC_ENABLED,
 };
 
@@ -195,12 +194,6 @@ enum i40e_ring_state_t {
 	set_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
 #define clear_check_for_tx_hang(ring) \
 	clear_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
-#define ring_is_lro_enabled(ring) \
-	test_bit(__I40E_RX_LRO_ENABLED, &(ring)->state)
-#define set_ring_lro_enabled(ring) \
-	set_bit(__I40E_RX_LRO_ENABLED, &(ring)->state)
-#define clear_ring_lro_enabled(ring) \
-	clear_bit(__I40E_RX_LRO_ENABLED, &(ring)->state)
 #define ring_is_16byte_desc_enabled(ring) \
 	test_bit(__I40E_RX_16BYTE_DESC_ENABLED, &(ring)->state)
 #define set_ring_16byte_desc_enabled(ring) \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index af639d8..e297a3a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -178,7 +178,6 @@ enum i40e_ring_state_t {
 	__I40E_TX_DETECT_HANG,
 	__I40E_HANG_CHECK_ARMED,
 	__I40E_RX_PS_ENABLED,
-	__I40E_RX_LRO_ENABLED,
 	__I40E_RX_16BYTE_DESC_ENABLED,
 };
 
@@ -194,12 +193,6 @@ enum i40e_ring_state_t {
 	set_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
 #define clear_check_for_tx_hang(ring) \
 	clear_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
-#define ring_is_lro_enabled(ring) \
-	test_bit(__I40E_RX_LRO_ENABLED, &(ring)->state)
-#define set_ring_lro_enabled(ring) \
-	set_bit(__I40E_RX_LRO_ENABLED, &(ring)->state)
-#define clear_ring_lro_enabled(ring) \
-	clear_bit(__I40E_RX_LRO_ENABLED, &(ring)->state)
 #define ring_is_16byte_desc_enabled(ring) \
 	test_bit(__I40E_RX_16BYTE_DESC_ENABLED, &(ring)->state)
 #define set_ring_16byte_desc_enabled(ring) \
-- 
1.9.3
