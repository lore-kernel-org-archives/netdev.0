From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 2/7] ixgbe: remove linux/export.h header from ixgbe_ptp.c
Date: Wed,  4 Jun 2014 00:04:55 -0700
Message-ID: <1401865500-18081-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401865500-18081-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21691 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305AbaFDHFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 03:05:05 -0400
In-Reply-To: <1401865500-18081-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We don't need this header file, so we shouldn't be including it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index b3266b7..68f87ec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -26,7 +26,6 @@
 
 *******************************************************************************/
 #include "ixgbe.h"
-#include <linux/export.h>
 #include <linux/ptp_classify.h>
 
 /*
-- 
1.9.3
