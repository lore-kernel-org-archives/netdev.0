From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e/i40evf: remove FTYPE
Date: Wed, 11 Jun 2014 09:33:20 -0700
Message-ID: <1402504404-8954-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55595 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932631AbaFKQdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:31 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change drops the FTYPE field from the Rx descriptor, to
match the hardware implementation.

Change-ID: I66d31d2b43861da45e8ace4fb03df033abe88bab
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 42bfb2a..bb5b055 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -663,7 +663,6 @@ enum i40e_rx_desc_ext_status_bits {
 	I40E_RX_DESC_EXT_STATUS_L2TAG3P_SHIFT	= 1,
 	I40E_RX_DESC_EXT_STATUS_FLEXBL_SHIFT	= 2, /* 2 BITS */
 	I40E_RX_DESC_EXT_STATUS_FLEXBH_SHIFT	= 4, /* 2 BITS */
-	I40E_RX_DESC_EXT_STATUS_FTYPE_SHIFT	= 6, /* 3 BITS */
 	I40E_RX_DESC_EXT_STATUS_FDLONGB_SHIFT	= 9,
 	I40E_RX_DESC_EXT_STATUS_FCOELONGB_SHIFT	= 10,
 	I40E_RX_DESC_EXT_STATUS_PELONGB_SHIFT	= 11,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 0a7914d..92fae73 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -663,7 +663,6 @@ enum i40e_rx_desc_ext_status_bits {
 	I40E_RX_DESC_EXT_STATUS_L2TAG3P_SHIFT	= 1,
 	I40E_RX_DESC_EXT_STATUS_FLEXBL_SHIFT	= 2, /* 2 BITS */
 	I40E_RX_DESC_EXT_STATUS_FLEXBH_SHIFT	= 4, /* 2 BITS */
-	I40E_RX_DESC_EXT_STATUS_FTYPE_SHIFT	= 6, /* 3 BITS */
 	I40E_RX_DESC_EXT_STATUS_FDLONGB_SHIFT	= 9,
 	I40E_RX_DESC_EXT_STATUS_FCOELONGB_SHIFT	= 10,
 	I40E_RX_DESC_EXT_STATUS_PELONGB_SHIFT	= 11,
-- 
1.9.3
