From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] ixgbe: remove IXGBE_FLAG_MSI(X)_CAPABLE flags
Date: Thu, 18 Sep 2014 05:27:01 -0700
Message-ID: <1411043221-7163-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43214 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753874AbaIRM1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:07 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

They were not used, and we don't need them, so we shouldn't bother with
keeping values in the flags field that could be misleading.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 75a56fa..673d820 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -611,9 +611,7 @@ struct ixgbe_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 0)
 #define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 1)
-#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 2)
 #define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 3)
 #define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 4)
 #define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 5)
-- 
1.9.3
