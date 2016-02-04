From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/20] i40e: update features with right offload
Date: Thu,  4 Feb 2016 03:48:59 -0800
Message-ID: <1454586551-35919-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965765AbcBDLtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:20 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Synchronize code bases and add SCTP offload support.

Change-ID: I9f99071f7176225479026930c387bf681a47494e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1a7022c..486ae16 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8947,11 +8947,11 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	np = netdev_priv(netdev);
 	np->vsi = vsi;
 
-	netdev->hw_enc_features |= NETIF_F_IP_CSUM	 |
-				  NETIF_F_RXCSUM	 |
-				  NETIF_F_GSO_UDP_TUNNEL |
-				  NETIF_F_GSO_GRE	 |
-				  NETIF_F_TSO;
+	netdev->hw_enc_features |= NETIF_F_IP_CSUM	  |
+				   NETIF_F_GSO_UDP_TUNNEL |
+				   NETIF_F_GSO_GRE	  |
+				   NETIF_F_TSO		  |
+				   0;
 
 	netdev->features = NETIF_F_SG		       |
 			   NETIF_F_IP_CSUM	       |
-- 
2.5.0
