From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbe: fix reporting of spoofed packets
Date: Sun, 16 Sep 2012 21:15:38 -0700
Message-ID: <1347855342-6610-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46001 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787Ab2IQEPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:49 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Use %u instead of %d to display u32 variable.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Robert Garrett <RobertX.Garrett@intel.com>
Tested-by: Robert Garrett <RobertX.Garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ac91567..e641f14 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5573,7 +5573,7 @@ static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
 	if (!ssvpc)
 		return;
 
-	e_warn(drv, "%d Spoofed packets detected\n", ssvpc);
+	e_warn(drv, "%u Spoofed packets detected\n", ssvpc);
 }
 
 /**
-- 
1.7.11.4
