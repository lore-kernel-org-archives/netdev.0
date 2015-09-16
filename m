From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/18] fm10k: TRIVIAL fix typo in fm10k_netdev.c
Date: Tue, 15 Sep 2015 17:36:40 -0700
Message-ID: <1442363803-47237-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58335 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbbIPAgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:50 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 3a6230b..639263d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1048,7 +1048,7 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 					   vid, true, 0);
 	}
 
-	/* update xcast mode before syncronizing addresses */
+	/* update xcast mode before synchronizing addresses */
 	hw->mac.ops.update_xcast_mode(hw, glort, xcast_mode);
 
 	/* synchronize all of the addresses */
-- 
2.4.3
