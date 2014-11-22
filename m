From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] i40e: Add a virtual channel op to config RSS
Date: Fri, 21 Nov 2014 21:54:57 -0800
Message-ID: <1416635708-4765-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50713 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbaKVFzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:15 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
