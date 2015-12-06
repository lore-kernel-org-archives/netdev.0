From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/15] fm10k: Correct typecast in fm10k_update_xc_addr_pf
Date: Sun,  6 Dec 2015 00:01:24 -0800
Message-ID: <1449388894-128573-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913AbbLFIBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:37 -0500
In-Reply-To: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since the resultant data type of the mac_update.mac_upper field is u16,
it does not make sense to typecast u8 variables to u32 first. Since
we're modifying fm10k_pf.c, also update the copyright year.

Reported-by: Matthew Vick <matthew.vick@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 8c0bdc4..b1e0975 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -334,8 +334,8 @@ static s32 fm10k_update_xc_addr_pf(struct fm10k_hw *hw, u16 glort,
 						 ((u32)mac[3] << 16) |
 						 ((u32)mac[4] << 8) |
 						 ((u32)mac[5]));
-	mac_update.mac_upper = cpu_to_le16(((u32)mac[0] << 8) |
-						 ((u32)mac[1]));
+	mac_update.mac_upper = cpu_to_le16(((u16)mac[0] << 8) |
+					   ((u16)mac[1]));
 	mac_update.vlan = cpu_to_le16(vid);
 	mac_update.glort = cpu_to_le16(glort);
 	mac_update.action = add ? 0 : 1;
-- 
2.5.0
