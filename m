From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: Resolve NULL reference by setting {read, write}_reg_mdi
Date: Fri, 23 Sep 2016 00:51:36 -0700
Message-ID: <1474617103-59530-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:6929 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757328AbcIWHvr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:47 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Set the read_reg_mdi and write_reg_mdi method pointers for
X550EM_A_10G_T devices to resolve jumping to NULL.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index dec8b11..cd22efb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3049,6 +3049,8 @@ static const struct ixgbe_phy_operations phy_ops_x550em_a = {
 	.identify		= &ixgbe_identify_phy_x550em,
 	.read_reg		= &ixgbe_read_phy_reg_x550a,
 	.write_reg		= &ixgbe_write_phy_reg_x550a,
+	.read_reg_mdi		= &ixgbe_read_phy_reg_mdi,
+	.write_reg_mdi		= &ixgbe_write_phy_reg_mdi,
 };
 
 static const u32 ixgbe_mvals_X550[IXGBE_MVALS_IDX_LIMIT] = {
-- 
2.7.4
