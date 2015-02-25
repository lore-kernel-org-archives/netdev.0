From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: Set BUF flag for Set Version AQ command
Date: Wed, 25 Feb 2015 00:58:34 -0800
Message-ID: <1424854720-18825-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2484 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748AbbBYI6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:48 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

BUF flag must be set for indirect AQ command.

Change-ID: I6819718a47baf69d1a91ebaed89f735ed6e86025
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index b7f5063..34bf5be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1794,7 +1794,7 @@ i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
 
 	i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_driver_version);
 
-	desc.flags |= cpu_to_le16(I40E_AQ_FLAG_SI);
+	desc.flags |= cpu_to_le16(I40E_AQ_FLAG_BUF | I40E_AQ_FLAG_SI);
 	cmd->driver_major_ver = dv->major_version;
 	cmd->driver_minor_ver = dv->minor_version;
 	cmd->driver_build_ver = dv->build_version;
-- 
1.9.3
