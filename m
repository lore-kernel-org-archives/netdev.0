From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 03/15] i40evf: trivial fixes
Date: Thu, 13 Feb 2014 03:48:41 -0800
Message-ID: <1392292133-32120-4-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20333 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753917AbaBMLvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:11 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change moves one operator up to the previous line and deletes
the duplicate declaration of ETH_ALEN.

Also update copyrights.

Change-ID: I88de73093b584e0f3b29d481ccd83fc4b1a1afa5
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 6 +++---
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 4 +---
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 3bb7558..827bb5f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 Intel Corporation.
+ * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -807,8 +807,8 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 	rx_desc = I40E_RX_DESC(rx_ring, i);
 	qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK)
-				>> I40E_RXD_QW1_STATUS_SHIFT;
+	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
+		    I40E_RXD_QW1_STATUS_SHIFT;
 
 	while (rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)) {
 		union i40e_rx_desc *next_rxd;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 3bffac0..092aace 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 Intel Corporation.
+ * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -64,8 +64,6 @@
 struct i40e_hw;
 typedef void (*I40E_ADMINQ_CALLBACK)(struct i40e_hw *, struct i40e_aq_desc *);
 
-#define ETH_ALEN	6
-
 /* Data type manipulation macros. */
 
 #define I40E_DESC_UNUSED(R)	\
-- 
1.8.5.GIT
