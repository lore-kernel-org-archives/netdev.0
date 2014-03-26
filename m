From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: Add an FD message level
Date: Wed, 26 Mar 2014 11:03:27 -0700
Message-ID: <1395857013-7568-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18894 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178AbaCZSE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:28 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

To use for Flow Director specific messages.

Change-ID: I69e39a410aa2661f8fd1ed6af0126fa4c335cb77
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index d2f0b95..71a968f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -91,6 +91,7 @@ enum i40e_debug_mask {
 	I40E_DEBUG_FLOW			= 0x00000200,
 	I40E_DEBUG_DCB			= 0x00000400,
 	I40E_DEBUG_DIAG			= 0x00000800,
+	I40E_DEBUG_FD			= 0x00001000,
 
 	I40E_DEBUG_AQ_MESSAGE		= 0x01000000,
 	I40E_DEBUG_AQ_DESCRIPTOR	= 0x02000000,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index efe73ad..4673b33 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -88,6 +88,7 @@ enum i40e_debug_mask {
 	I40E_DEBUG_FLOW			= 0x00000200,
 	I40E_DEBUG_DCB			= 0x00000400,
 	I40E_DEBUG_DIAG			= 0x00000800,
+	I40E_DEBUG_FD			= 0x00001000,
 
 	I40E_DEBUG_AQ_MESSAGE		= 0x01000000,
 	I40E_DEBUG_AQ_DESCRIPTOR	= 0x02000000,
-- 
1.8.3.1
