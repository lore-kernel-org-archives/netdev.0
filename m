From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] i40e: clean up historic deprecated flag definitions
Date: Sat,  8 Apr 2017 02:55:50 -0700
Message-ID: <20170408095553.78307-10-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25320 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751764AbdDHJ4N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:56:13 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since an early commit a few flags have no longer
been used. Remove these definitions to reduce code clutter.

Change-ID: I3589be4622574e747013cd4dc403e18b039f4965
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ef64dc60f857..e987503f8517 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -390,11 +390,8 @@ struct i40e_pf {
 #define I40E_FLAG_RSS_ENABLED			BIT_ULL(6)
 #define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
 #define I40E_FLAG_IWARP_ENABLED			BIT_ULL(10)
-#define I40E_FLAG_CLEAN_ADMINQ			BIT_ULL(14)
 #define I40E_FLAG_FILTER_SYNC			BIT_ULL(15)
 #define I40E_FLAG_SERVICE_CLIENT_REQUESTED	BIT_ULL(16)
-#define I40E_FLAG_PROCESS_MDD_EVENT		BIT_ULL(17)
-#define I40E_FLAG_PROCESS_VFLR_EVENT		BIT_ULL(18)
 #define I40E_FLAG_SRIOV_ENABLED			BIT_ULL(19)
 #define I40E_FLAG_DCB_ENABLED			BIT_ULL(20)
 #define I40E_FLAG_FD_SB_ENABLED			BIT_ULL(21)
-- 
2.12.2
