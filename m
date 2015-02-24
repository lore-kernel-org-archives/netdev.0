From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/16] i40e: Use #define for the VSI connection type
Date: Mon, 23 Feb 2015 18:11:13 -0800
Message-ID: <1424743881-30485-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7500 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426AbbBXCLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:32 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Use #defined VSI connection type values instead of using magic numbers.

Change-ID: I2f6cf7bf394d391e1c0fe61779e9e4ad8858154a
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 27c206e..8b5bf16 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -381,7 +381,7 @@ int i40e_fcoe_vsi_init(struct i40e_vsi *vsi, struct i40e_vsi_context *ctxt)
 	ctxt->pf_num = hw->pf_id;
 	ctxt->vf_num = 0;
 	ctxt->uplink_seid = vsi->uplink_seid;
-	ctxt->connection_type = 0x1;
+	ctxt->connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 	ctxt->flags = I40E_AQ_VSI_TYPE_PF;
 
 	/* FCoE VSI would need the following sections */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 10ad1ee..e3597cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7863,7 +7863,7 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		ctxt.pf_num = hw->pf_id;
 		ctxt.vf_num = 0;
 		ctxt.uplink_seid = vsi->uplink_seid;
-		ctxt.connection_type = 0x1;     /* regular data port */
+		ctxt.connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 		ctxt.flags = I40E_AQ_VSI_TYPE_PF;
 		ctxt.info.valid_sections |=
 				cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
@@ -7876,7 +7876,7 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		ctxt.pf_num = hw->pf_id;
 		ctxt.vf_num = 0;
 		ctxt.uplink_seid = vsi->uplink_seid;
-		ctxt.connection_type = 0x1;     /* regular data port */
+		ctxt.connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 		ctxt.flags = I40E_AQ_VSI_TYPE_VMDQ2;
 
 		ctxt.info.valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
@@ -7895,7 +7895,7 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		ctxt.pf_num = hw->pf_id;
 		ctxt.vf_num = vsi->vf_id + hw->func_caps.vf_base_id;
 		ctxt.uplink_seid = vsi->uplink_seid;
-		ctxt.connection_type = 0x1;     /* regular data port */
+		ctxt.connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 		ctxt.flags = I40E_AQ_VSI_TYPE_VF;
 
 		ctxt.info.valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
-- 
1.9.3
