From: Babu Moger <babu.moger@oracle.com>
Subject: [PATCH] ixgbe: Fix minor typo while freeing irq
Date: Sat, 18 Jun 2016 17:40:47 -0700
Message-ID: <1466296847-82299-1-git-send-email-babu.moger@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	babu.moger@oracle.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31354 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbcFSAlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 20:41:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The array subscript increments after the execution of the statement.
So there is no issue here. However it helps to read the code better.

Signed-off-by: Babu Moger <babu.moger@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 569cb07..6f4fe66 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3016,7 +3016,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		free_irq(entry->vector, q_vector);
 	}
 
-	free_irq(adapter->msix_entries[vector++].vector, adapter);
+	free_irq(adapter->msix_entries[vector].vector, adapter);
 }
 
 /**
-- 
1.7.1
