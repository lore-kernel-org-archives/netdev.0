From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/16] i40e: Add a virtual channel op to config RSS
Date: Sat,  6 Dec 2014 05:02:03 -0800
Message-ID: <1417870933-17248-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbaLFNC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:58 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add the Virtual Channel OP event opcode for CONFIG_RSS, so that the
Virtual Channel state machine can properly decipher status change events.

Change-ID: I09939c7aa380147f60c49fd01ef2e27d0dc1c299
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 70951d2..61dd1b18 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -79,6 +79,7 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE,
 	I40E_VIRTCHNL_OP_GET_STATS,
 	I40E_VIRTCHNL_OP_FCOE,
+	I40E_VIRTCHNL_OP_CONFIG_RSS,
 /* PF sends status change events to vfs using
  * the following op.
  */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index cd18d56..e0c8208 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -79,6 +79,7 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_CONFIG_PROMISCUOUS_MODE,
 	I40E_VIRTCHNL_OP_GET_STATS,
 	I40E_VIRTCHNL_OP_FCOE,
+	I40E_VIRTCHNL_OP_CONFIG_RSS,
 /* PF sends status change events to vfs using
  * the following op.
  */
-- 
1.9.3
