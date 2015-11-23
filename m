From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] ixgbe: Delete redundant include file
Date: Mon, 23 Nov 2015 11:36:05 -0800
Message-ID: <1448307376-20063-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40449 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496AbbKWTgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:22 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Delete a redundant include of net/vxlan.h.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4089d77..450db04 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -65,9 +65,6 @@
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"
-#ifdef CONFIG_IXGBE_VXLAN
-#include <net/vxlan.h>
-#endif
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
-- 
2.5.0
