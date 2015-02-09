From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: i40e_fcoe.c: Remove unused function
Date: Mon,  9 Feb 2015 02:43:47 -0800
Message-ID: <1423478641-3138-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38701 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759974AbbBIKoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:04 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Remove the function i40e_rx_is_fip() that is not used anywhere.

This was partially found by using a static code analysis program
called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 2cd841b..dc8cbdd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -39,15 +39,6 @@
 #include "i40e_fcoe.h"
 
 /**
- * i40e_rx_is_fip - returns true if the rx packet type is FIP
- * @ptype: the packet type field from rx descriptor write-back
- **/
-static inline bool i40e_rx_is_fip(u16 ptype)
-{
-	return ptype == I40E_RX_PTYPE_L2_FIP_PAY2;
-}
-
-/**
  * i40e_rx_is_fcoe - returns true if the rx packet type is FCoE
  * @ptype: the packet type field from rx descriptor write-back
  **/
-- 
1.9.3
