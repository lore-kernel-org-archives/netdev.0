From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/6] dccp: cosmetics of info message
Date: Mon,  4 Jul 2011 13:01:16 -0600
Message-ID: <1309806079-21604-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2011-07-04>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53739 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751517Ab1GDTUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 15:20:55 -0400
In-Reply-To: <test_tree_patch_set_update_2011-07-04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the CCID (de)activation message to start with the
protocol name, as 'CCID' is already in there.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -118,7 +118,7 @@ static int ccid_activate(struct ccid_operations *ccid_ops)
 	if (ccid_ops->ccid_hc_tx_slab == NULL)
 		goto out_free_rx_slab;
 
-	pr_info("CCID: Activated CCID %d (%s)\n",
+	pr_info("DCCP: Activated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 	err = 0;
 out:
@@ -136,7 +136,7 @@ static void ccid_deactivate(struct ccid_operations *ccid_ops)
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
 	ccid_ops->ccid_hc_rx_slab = NULL;
 
-	pr_info("CCID: Deactivated CCID %d (%s)\n",
+	pr_info("DCCP: Deactivated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 }
 
