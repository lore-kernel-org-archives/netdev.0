From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] fm10k: cleanup SPACE_BEFORE_TAB checkpatch warning
Date: Tue,  5 Apr 2016 01:01:17 -0700
Message-ID: <1459843288-40623-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5422 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbcDEIBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:01:52 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index b4945e8..1c1ccad 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -416,7 +416,7 @@ void fm10k_ptp_register(struct fm10k_intfc *interface)
 	/* This math is simply the inverse of the math in
 	 * fm10k_adjust_systime_pf applied to an adjustment value
 	 * of 2^30 - 1 which is the maximum value of the register:
-	 * 	max_ppb == ((2^30 - 1) * 5^9) / 2^31
+	 *	max_ppb == ((2^30 - 1) * 5^9) / 2^31
 	 */
 	ptp_caps->max_adj	= 976562;
 	ptp_caps->adjfreq	= fm10k_ptp_adjfreq;
-- 
2.5.5
