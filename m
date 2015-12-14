From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] fm10k: do not use CamelCase
Date: Sun, 13 Dec 2015 16:27:34 -0800
Message-ID: <1450052867-36654-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729AbbLNA1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:50 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Avoid the use of CamelCase for some variable names that previously
slipped through review.

Reported-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  | 12 ++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h | 14 +++++++-------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 15d8e10..644b0c1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1411,14 +1411,14 @@ static int fm10k_mbx_request_irq_pf(struct fm10k_intfc *interface)
 	}
 
 	/* Enable interrupts w/ no moderation for "other" interrupts */
-	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_PCIeFault), other_itr);
-	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_SwitchUpDown), other_itr);
-	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_SRAM), other_itr);
-	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_MaxHoldTime), other_itr);
-	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_VFLR), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_pcie_fault), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_switch_up_down), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_sram), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_max_hold_time), other_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_vflr), other_itr);
 
 	/* Enable interrupts w/ moderation for mailbox */
-	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_Mailbox), mbx_itr);
+	fm10k_write_reg(hw, FM10K_INT_MAP(fm10k_int_mailbox), mbx_itr);
 
 	/* Enable individual interrupt causes */
 	fm10k_write_reg(hw, FM10K_EIMR, FM10K_EIMR_ENABLE(PCA_FAULT) |
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 0272725..2fd962f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -388,13 +388,13 @@ struct fm10k_hw;
 #define FM10K_SW_SYSTIME_PULSE(_n)	((_n) + 0x02252)
 
 enum fm10k_int_source {
-	fm10k_int_Mailbox	= 0,
-	fm10k_int_PCIeFault	= 1,
-	fm10k_int_SwitchUpDown	= 2,
-	fm10k_int_SwitchEvent	= 3,
-	fm10k_int_SRAM		= 4,
-	fm10k_int_VFLR		= 5,
-	fm10k_int_MaxHoldTime	= 6,
+	fm10k_int_mailbox		= 0,
+	fm10k_int_pcie_fault		= 1,
+	fm10k_int_switch_up_down	= 2,
+	fm10k_int_switch_event		= 3,
+	fm10k_int_sram			= 4,
+	fm10k_int_vflr			= 5,
+	fm10k_int_max_hold_time		= 6,
 	fm10k_int_sources_max_pf
 };
 
-- 
2.5.0
