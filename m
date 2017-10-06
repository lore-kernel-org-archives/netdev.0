From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: redfine I40E_PHY_TYPE_MAX
Date: Fri,  6 Oct 2017 10:57:17 -0700
Message-ID: <20171006175727.868-6-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12575 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752518AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Since I40E_PHY_TYPE_MAX is used as an iterator, usually combined with
some sort of bit-shifting, it should only include actual PHY types and
not error cases. Move it up in the enum declaration so that loops only
iterate across valid PHY types.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 4c85ea9cd89a..50c5a4c630b8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1771,9 +1771,9 @@ enum i40e_aq_phy_type {
 	I40E_PHY_TYPE_25GBASE_CR		= 0x20,
 	I40E_PHY_TYPE_25GBASE_SR		= 0x21,
 	I40E_PHY_TYPE_25GBASE_LR		= 0x22,
+	I40E_PHY_TYPE_MAX,
 	I40E_PHY_TYPE_EMPTY			= 0xFE,
 	I40E_PHY_TYPE_DEFAULT			= 0xFF,
-	I40E_PHY_TYPE_MAX
 };
 
 #define I40E_LINK_SPEED_100MB_SHIFT	0x1
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index ed5602f4bbcd..dc6fc8b1bc79 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1767,9 +1767,9 @@ enum i40e_aq_phy_type {
 	I40E_PHY_TYPE_25GBASE_CR		= 0x20,
 	I40E_PHY_TYPE_25GBASE_SR		= 0x21,
 	I40E_PHY_TYPE_25GBASE_LR		= 0x22,
+	I40E_PHY_TYPE_MAX,
 	I40E_PHY_TYPE_EMPTY			= 0xFE,
 	I40E_PHY_TYPE_DEFAULT			= 0xFF,
-	I40E_PHY_TYPE_MAX
 };
 
 #define I40E_LINK_SPEED_100MB_SHIFT	0x1
-- 
2.14.2
