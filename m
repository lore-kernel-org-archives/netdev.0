From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: add header file flag _I40E_TXRX_H_
Date: Sun,  5 Jan 2014 02:46:58 -0800
Message-ID: <1388918827-13430-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26680 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbaAEKrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:13 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Add an include header guard to guard against multiple includes

Change-Id: I73efa03efc912d2047edab903c7caed05b444da2
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 2992830..92f5cf5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -25,6 +25,9 @@
  *
  ******************************************************************************/
 
+#ifndef _I40E_TXRX_H_
+#define _I40E_TXRX_H_
+
 /* Interrupt Throttling and Rate Limiting (storm control) Goodies */
 
 #define I40E_MAX_ITR               0x07FF
@@ -295,3 +298,4 @@ int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring);
 void i40e_free_tx_resources(struct i40e_ring *tx_ring);
 void i40e_free_rx_resources(struct i40e_ring *rx_ring);
 int i40e_napi_poll(struct napi_struct *napi, int budget);
+#endif /* _I40E_TXRX_H_ */
-- 
1.8.3.1
