From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbe: fix multiple kernel-doc errors
Date: Mon, 23 Nov 2015 11:36:06 -0800
Message-ID: <1448307376-20063-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56820 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754798AbbKWTgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:22 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The commit dfaf891dd3e1 ("ixgbe: Refactor the RSS configuration code")
introduced a few kernel-doc errors:

1) The function name is missing;
2) The format is wrong;
3) The short description is redundant.

Fix all the above for the correct execution of the kernel doc.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 450db04..c9b7e5e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3312,8 +3312,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 }
 
 /**
- * Return a number of entries in the RSS indirection table
- *
+ * ixgbe_rss_indir_tbl_entries - Return RSS indirection table entries
  * @adapter: device handle
  *
  *  - 82598/82599/X540:     128
@@ -3331,8 +3330,7 @@ u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter)
 }
 
 /**
- * Write the RETA table to HW
- *
+ * ixgbe_store_reta - Write the RETA table to HW
  * @adapter: device handle
  *
  * Write the RSS redirection table stored in adapter.rss_indir_tbl[] to HW.
@@ -3371,8 +3369,7 @@ void ixgbe_store_reta(struct ixgbe_adapter *adapter)
 }
 
 /**
- * Write the RETA table to HW (for x550 devices in SRIOV mode)
- *
+ * ixgbe_store_vfreta - Write the RETA table to HW (x550 devices in SRIOV mode)
  * @adapter: device handle
  *
  * Write the RSS redirection table stored in adapter.rss_indir_tbl[] to HW.
-- 
2.5.0
