From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] i40e: remove I40E_FLAG_NEED_LINK_UPDATE
Date: Sat,  8 Apr 2017 02:55:49 -0700
Message-ID: <20170408095553.78307-9-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Alice Michael <alice.michael@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55938 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752013AbdDHJ4M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:56:12 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alice Michael <alice.michael@intel.com>

The I40E_FLAG_NEED_LINK_UPDATE was never used. Remove the flag
definitions.

Change-ID: If59d0c6b4af85ca27281f3183c54b055adb439a4
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 drivers/net/ethernet/intel/i40evf/i40evf.h  | 1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 110ef4204306..ef64dc60f857 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -389,7 +389,6 @@ struct i40e_pf {
 #define I40E_FLAG_MSIX_ENABLED			BIT_ULL(3)
 #define I40E_FLAG_RSS_ENABLED			BIT_ULL(6)
 #define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
-#define I40E_FLAG_NEED_LINK_UPDATE		BIT_ULL(9)
 #define I40E_FLAG_IWARP_ENABLED			BIT_ULL(10)
 #define I40E_FLAG_CLEAN_ADMINQ			BIT_ULL(14)
 #define I40E_FLAG_FILTER_SYNC			BIT_ULL(15)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0e1240b704ef..3b1dab7a7cc9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11091,7 +11091,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	INIT_WORK(&pf->service_task, i40e_service_task);
 	clear_bit(__I40E_SERVICE_SCHED, &pf->state);
-	pf->flags |= I40E_FLAG_NEED_LINK_UPDATE;
 
 	/* NVM bit on means WoL disabled for the port */
 	i40e_read_nvm_word(hw, I40E_SR_NVM_WAKE_ON_LAN, &wol_nvm_bits);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index d61ecf655091..35ded19e9cc2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -205,7 +205,6 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_IN_NETPOLL			BIT(4)
 #define I40EVF_FLAG_IMIR_ENABLED		BIT(5)
 #define I40EVF_FLAG_MQ_CAPABLE			BIT(6)
-#define I40EVF_FLAG_NEED_LINK_UPDATE		BIT(7)
 #define I40EVF_FLAG_PF_COMMS_FAILED		BIT(8)
 #define I40EVF_FLAG_RESET_PENDING		BIT(9)
 #define I40EVF_FLAG_RESET_NEEDED		BIT(10)
-- 
2.12.2
