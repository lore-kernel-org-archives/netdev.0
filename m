From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] i40e: Store off PHY capabilities
Date: Thu, 15 Oct 2015 02:39:59 -0700
Message-ID: <1444902004-14433-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019AbbJOJmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:31 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Store off reported PHY capabilities in link_info structure.

Change-ID: Ife0f037c26983ca985dbf79abf33f8f8791369e8
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index ffd1cd0..d1ee174 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1617,6 +1617,9 @@ i40e_status i40e_aq_get_phy_capabilities(struct i40e_hw *hw,
 	if (hw->aq.asq_last_status == I40E_AQ_RC_EIO)
 		status = I40E_ERR_UNKNOWN_PHY;
 
+	if (report_init)
+		hw->phy.phy_types = le32_to_cpu(abilities->phy_type);
+
 	return status;
 }
 
-- 
2.4.3
