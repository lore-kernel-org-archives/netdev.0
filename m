From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: remove I40E_FLAG_IN_NETPOLL entirely
Date: Wed, 19 Apr 2017 18:57:47 -0700
Message-ID: <20170420015750.6828-12-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:20804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939107AbdDTB6C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:58:02 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This flag was originally intended to be used to let some
driver code know when we were running from netpoll.
Ultimately this was not necessary and we never used it.
Let's remove it

Change-ID: I43b72483d91c1638071d2a7f389ab171ec5b796a
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 7bbd11abed08..40f56e2335df 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -202,7 +202,6 @@ struct i40evf_adapter {
 
 	u32 flags;
 #define I40EVF_FLAG_RX_CSUM_ENABLED		BIT(0)
-#define I40EVF_FLAG_IN_NETPOLL			BIT(4)
 #define I40EVF_FLAG_IMIR_ENABLED		BIT(5)
 #define I40EVF_FLAG_MQ_CAPABLE			BIT(6)
 #define I40EVF_FLAG_PF_COMMS_FAILED		BIT(8)
@@ -221,7 +220,6 @@ struct i40evf_adapter {
 /* duplicates for common code */
 #define I40E_FLAG_FDIR_ATR_ENABLED		0
 #define I40E_FLAG_DCB_ENABLED			0
-#define I40E_FLAG_IN_NETPOLL			I40EVF_FLAG_IN_NETPOLL
 #define I40E_FLAG_RX_CSUM_ENABLED		I40EVF_FLAG_RX_CSUM_ENABLED
 #define I40E_FLAG_WB_ON_ITR_CAPABLE		I40EVF_FLAG_WB_ON_ITR_CAPABLE
 #define I40E_FLAG_OUTER_UDP_CSUM_CAPABLE	I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE
-- 
2.12.2
