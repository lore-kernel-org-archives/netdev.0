From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/20] i40e: Add mac_filter_element at the end of the list instead of HEAD
Date: Thu,  4 Feb 2016 03:48:52 -0800
Message-ID: <1454586551-35919-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28296 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933844AbcBDLtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:14 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

Add MAC filter element to the end of the list in the given order,
just to be tidy, and just in case there are ever any ordering issues in
the future.

Change-ID: Idc15276147593ea9393ac72c861f9c7905a791b4
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8f3b53e..d078a63 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1368,7 +1368,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 		f->changed = true;
 
 		INIT_LIST_HEAD(&f->list);
-		list_add(&f->list, &vsi->mac_filter_list);
+		list_add_tail(&f->list, &vsi->mac_filter_list);
 	}
 
 	/* increment counter and add a new flag if needed */
-- 
2.5.0
