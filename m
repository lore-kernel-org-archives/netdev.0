From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/14] i40e/i40evf: remove reserved type
Date: Tue, 24 Jun 2014 18:26:18 -0700
Message-ID: <1403659585-32055-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35161 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754263AbaFYB0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 21:26:41 -0400
In-Reply-To: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

One of the PCTYPES that was moved to a reserved value
wasn't removed from the code.

Change-ID: I31fafe6d79c5f5128179979af5eaafa8c0cd62fe
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 1 -
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 1 -
 4 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 0277894..f09fb3e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -75,7 +75,6 @@ enum i40e_dyn_idx_t {
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) | \
 	((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_SCTP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) | \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 1c0d5a7..11dd2dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -878,7 +878,6 @@ enum i40e_filter_pctype {
 	I40E_FILTER_PCTYPE_FRAG_IPV4			= 36,
 	/* Note: Values 37-40 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV6_UDP		= 41,
-	I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN		= 42,
 	I40E_FILTER_PCTYPE_NONF_IPV6_TCP		= 43,
 	I40E_FILTER_PCTYPE_NONF_IPV6_SCTP		= 44,
 	I40E_FILTER_PCTYPE_NONF_IPV6_OTHER		= 45,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 30d248b..acd3c12 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -75,7 +75,6 @@ enum i40e_dyn_idx_t {
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) | \
 	((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_UDP) | \
-	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_SCTP) | \
 	((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) | \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 9c83578..23cd18b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -878,7 +878,6 @@ enum i40e_filter_pctype {
 	I40E_FILTER_PCTYPE_FRAG_IPV4			= 36,
 	/* Note: Values 37-40 are reserved for future use */
 	I40E_FILTER_PCTYPE_NONF_IPV6_UDP		= 41,
-	I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN		= 42,
 	I40E_FILTER_PCTYPE_NONF_IPV6_TCP		= 43,
 	I40E_FILTER_PCTYPE_NONF_IPV6_SCTP		= 44,
 	I40E_FILTER_PCTYPE_NONF_IPV6_OTHER		= 45,
-- 
1.9.3
