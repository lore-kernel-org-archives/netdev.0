From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: fix incorrect register definition
Date: Fri,  6 Oct 2017 10:57:18 -0700
Message-ID: <20171006175727.868-7-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17217 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752581AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This register was defined incorrectly. Fix the increment value to 8, and
replace the iterator with _i to make the definition consistent with
other statistics registers.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_register.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_register.h b/drivers/net/ethernet/intel/i40e/i40e_register.h
index 86ca27f72f02..c234758dad15 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_register.h
@@ -2794,7 +2794,7 @@
 #define I40E_GLV_RUPP_MAX_INDEX 383
 #define I40E_GLV_RUPP_RUPP_SHIFT 0
 #define I40E_GLV_RUPP_RUPP_MASK I40E_MASK(0xFFFFFFFF, I40E_GLV_RUPP_RUPP_SHIFT)
-#define I40E_GLV_TEPC(_VSI) (0x00344000 + ((_VSI) * 4)) /* _i=0...383 */ /* Reset: CORER */
+#define I40E_GLV_TEPC(_i) (0x00344000 + ((_i) * 8)) /* _i=0...383 */ /* Reset: CORER */
 #define I40E_GLV_TEPC_MAX_INDEX 383
 #define I40E_GLV_TEPC_TEPC_SHIFT 0
 #define I40E_GLV_TEPC_TEPC_MASK I40E_MASK(0xFFFFFFFF, I40E_GLV_TEPC_TEPC_SHIFT)
-- 
2.14.2
