From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] i40e: Remove unneeded break statement
Date: Fri, 21 Nov 2014 21:54:52 -0800
Message-ID: <1416635708-4765-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:24551 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbaKVFzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:12 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This case statement is empty and the fall through just breaks out
so remove the break and let it fall through to break out.

Change-ID: I1b5ba9870d5245ca80bfca6e7f5f089e2eb8ccb0
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3913329..308b4b6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5450,8 +5450,6 @@ static void i40e_vsi_link_event(struct i40e_vsi *vsi, bool link_up)
 		break;
 
 	case I40E_VSI_SRIOV:
-		break;
-
 	case I40E_VSI_VMDQ2:
 	case I40E_VSI_CTRL:
 	case I40E_VSI_MIRROR:
-- 
1.9.3
