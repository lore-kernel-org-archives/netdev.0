From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: Remove useless message
Date: Wed, 30 Sep 2015 05:52:34 -0700
Message-ID: <1443617561-40490-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34535 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932393AbbI3Mwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:45 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Remove a useless message that blathers on whenever a vxlan port is deleted.

Change-ID: If63fb8cf38e56cf433b68e498f11389de51919ba
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 940744a..032df6d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8175,9 +8175,6 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 		pf->vxlan_ports[idx] = 0;
 		pf->pending_vxlan_bitmap |= BIT_ULL(idx);
 		pf->flags |= I40E_FLAG_VXLAN_FILTER_SYNC;
-
-		dev_info(&pf->pdev->dev, "deleting vxlan port %d\n",
-			 ntohs(port));
 	} else {
 		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
 			    ntohs(port));
-- 
2.4.3
