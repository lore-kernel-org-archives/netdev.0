From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] ixgbe: Fix minor typo while freeing irq
Date: Fri, 22 Jul 2016 23:49:42 -0700
Message-ID: <1469256591-109822-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Babu Moger <babu.moger@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62671 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbcGWGuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:11 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Babu Moger <babu.moger@oracle.com>

The array subscript increments after the execution of the statement.
So there is no issue here. However it helps to read the code better.

Signed-off-by: Babu Moger <babu.moger@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 918b94b..f2837ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3084,7 +3084,7 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		free_irq(entry->vector, q_vector);
 	}
 
-	free_irq(adapter->msix_entries[vector++].vector, adapter);
+	free_irq(adapter->msix_entries[vector].vector, adapter);
 }
 
 /**
-- 
2.5.5
