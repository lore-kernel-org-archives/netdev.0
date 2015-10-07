From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/18] i40e/i40evf: remove unused opcode
Date: Wed,  7 Oct 2015 15:47:12 -0700
Message-ID: <1444258032-41476-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5168 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbbJGWr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:27 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This opcode is not required. VFs that program RSS through the firmware
do it by interacting directly with the firmware, and do not need to use
the virtual channel for this functionality.

Change-ID: Iaf17d2600e28ff1b6be8653f2fe9df1facd23b0e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 0f8d415..95d0f8c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -81,7 +81,6 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_GET_STATS = 15,
 	I40E_VIRTCHNL_OP_FCOE = 16,
 	I40E_VIRTCHNL_OP_EVENT = 17,
-	I40E_VIRTCHNL_OP_CONFIG_RSS = 18,
 };
 
 /* Virtual channel message descriptor. This overlays the admin queue
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index e6db20e..cadda64 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -81,7 +81,6 @@ enum i40e_virtchnl_ops {
 	I40E_VIRTCHNL_OP_GET_STATS = 15,
 	I40E_VIRTCHNL_OP_FCOE = 16,
 	I40E_VIRTCHNL_OP_EVENT = 17,
-	I40E_VIRTCHNL_OP_CONFIG_RSS = 18,
 };
 
 /* Virtual channel message descriptor. This overlays the admin queue
-- 
2.4.3
