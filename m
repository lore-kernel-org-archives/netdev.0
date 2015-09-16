From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/18] fm10k: TRIVIAL fix up ordering of __always_unused and style
Date: Tue, 15 Sep 2015 17:36:38 -0700
Message-ID: <1442363803-47237-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914AbbIPAgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:50 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Fix some style issues in debugfs code, and correct ordering of void and
__always_unused. Technically, the order does not matter, but preferred
style is to put the macro between the type and name.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
index f45b4d7..08ecf43 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
@@ -37,7 +37,8 @@ static void *fm10k_dbg_desc_seq_start(struct seq_file *s, loff_t *pos)
 }
 
 static void *fm10k_dbg_desc_seq_next(struct seq_file *s,
-				     void __always_unused *v, loff_t *pos)
+				     void __always_unused *v,
+				     loff_t *pos)
 {
 	struct fm10k_ring *ring = s->private;
 
@@ -45,7 +46,7 @@ static void *fm10k_dbg_desc_seq_next(struct seq_file *s,
 }
 
 static void fm10k_dbg_desc_seq_stop(struct seq_file __always_unused *s,
-				    __always_unused void *v)
+				    void __always_unused *v)
 {
 	/* Do nothing. */
 }
-- 
2.4.3
