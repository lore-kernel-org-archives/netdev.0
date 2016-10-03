From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/2] fm10k: wrap long line for alloc_workqueue
Date: Sun,  2 Oct 2016 23:40:43 -0700
Message-ID: <1475476843-23405-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19796 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752038AbcJCGkq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 02:40:46 -0400
In-Reply-To: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Trivial change here to cleanup a checkpatch.pl warning that got
introduced when changing to alloc_workqueue.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 0d39103..5de9378 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -56,7 +56,8 @@ static int __init fm10k_init_module(void)
 	pr_info("%s\n", fm10k_copyright);
 
 	/* create driver workqueue */
-	fm10k_workqueue = alloc_workqueue("%s", WQ_MEM_RECLAIM, 0, fm10k_driver_name);
+	fm10k_workqueue = alloc_workqueue("%s", WQ_MEM_RECLAIM, 0,
+					  fm10k_driver_name);
 
 	fm10k_dbg_init();
 
-- 
2.7.4
