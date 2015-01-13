From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: remove VN2VN related mac filters
Date: Tue, 13 Jan 2015 03:33:26 -0800
Message-ID: <1421148811-9763-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43855 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbbAMLdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:38 -0500
In-Reply-To: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

These mac address already added by FCoE stack above netdev,
therefore adding them here is redundant.

Change-ID: Ia5b59f426f57efd20f8945f7c6cc5d741fbe06e5
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index a8b8bd9..2cd841b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1515,8 +1515,6 @@ void i40e_fcoe_config_netdev(struct net_device *netdev, struct i40e_vsi *vsi)
 	i40e_add_filter(vsi, (u8[6]) FC_FCOE_FLOGI_MAC, 0, false, false);
 	i40e_add_filter(vsi, FIP_ALL_FCOE_MACS, 0, false, false);
 	i40e_add_filter(vsi, FIP_ALL_ENODE_MACS, 0, false, false);
-	i40e_add_filter(vsi, FIP_ALL_VN2VN_MACS, 0, false, false);
-	i40e_add_filter(vsi, FIP_ALL_P2P_MACS, 0, false, false);
 
 	/* use san mac */
 	ether_addr_copy(netdev->dev_addr, hw->mac.san_addr);
-- 
1.9.3
