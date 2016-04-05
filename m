From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] fm10k: demote BUG_ON() to WARN_ON() where appropriate
Date: Tue,  5 Apr 2016 01:01:16 -0700
Message-ID: <1459843288-40623-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2972 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757499AbcDEIC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:27 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

We don't need to crash the kernel in this instance so just warn about the
condition and play on.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index c9324c7..60a70e9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -99,7 +99,7 @@ void fm10k_service_event_schedule(struct fm10k_intfc *interface)
 
 static void fm10k_service_event_complete(struct fm10k_intfc *interface)
 {
-	BUG_ON(!test_bit(__FM10K_SERVICE_SCHED, &interface->state));
+	WARN_ON(!test_bit(__FM10K_SERVICE_SCHED, &interface->state));
 
 	/* flush memory to make sure state is correct before next watchog */
 	smp_mb__before_atomic();
-- 
2.5.5
