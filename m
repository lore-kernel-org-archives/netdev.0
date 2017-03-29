From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: remove FDIR_REQUIRES_REINIT driver flag
Date: Wed, 29 Mar 2017 03:12:08 -0700
Message-ID: <20170329101215.24513-7-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54616 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755289AbdC2KMY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:24 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This flag hasn't been used since commit 1e1be8f622ee ("i40e: ATR policy
change to flush the table to clean stale ATR rules").

Lets simplify things and just remove it.

Change-ID: I76279d84db8a2fd96f445b96aa413059f9256879
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f506e994861b..aa9ac2833edf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -389,7 +389,6 @@ struct i40e_pf {
 #define I40E_FLAG_MSIX_ENABLED			BIT_ULL(3)
 #define I40E_FLAG_RSS_ENABLED			BIT_ULL(6)
 #define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
-#define I40E_FLAG_FDIR_REQUIRES_REINIT		BIT_ULL(8)
 #define I40E_FLAG_NEED_LINK_UPDATE		BIT_ULL(9)
 #define I40E_FLAG_IWARP_ENABLED			BIT_ULL(10)
 #define I40E_FLAG_CLEAN_ADMINQ			BIT_ULL(14)
-- 
2.12.0
