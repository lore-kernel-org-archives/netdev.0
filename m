From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] i40e: fix trivial typo in naming of i40e_sync_filters_subtask
Date: Sat,  3 Dec 2016 01:19:19 -0800
Message-ID: <20161203091930.14268-8-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28618 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751608AbcLCJUj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:39 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A comment incorrectly referred to i40e_vsi_sync_filters_subtask which
does not actually exist. Reference the correct function instead.

Change-ID: I6bd805c605741ffb6fe34377259bb0d597edfafd
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fe5939a..6832ab1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1211,12 +1211,12 @@ bool i40e_is_vsi_in_vlan(struct i40e_vsi *vsi)
 	 *    i40e_add_filter.
 	 *
 	 * 2) the only place where filters are actually removed is in
-	 *    i40e_vsi_sync_filters_subtask.
+	 *    i40e_sync_filters_subtask.
 	 *
 	 * Thus, we can simply use a boolean value, has_vlan_filters which we
 	 * will set to true when we add a VLAN filter in i40e_add_filter. Then
 	 * we have to perform the full search after deleting filters in
-	 * i40e_vsi_sync_filters_subtask, but we already have to search
+	 * i40e_sync_filters_subtask, but we already have to search
 	 * filters here and can perform the check at the same time. This
 	 * results in avoiding embedding a loop for VLAN mode inside another
 	 * loop over all the filters, and should maintain correctness as noted
-- 
2.9.3
