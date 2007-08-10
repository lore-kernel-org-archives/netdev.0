From: akpm@linux-foundation.org
Subject: [patch 12/18] e1000: #if 0 two functions
Date: Fri, 10 Aug 2007 14:05:22 -0700
Message-ID: <200708102105.l7AL5M0O008980@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de,
	auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45122 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765214AbXHJVQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

e1000_{read,write}_pci_cfg() are no longer used.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000/e1000_hw.h   |    2 --
 drivers/net/e1000/e1000_main.c |    4 ++++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/e1000/e1000_hw.h~e1000-if-0-two-functions drivers/net/e1000/e1000_hw.h
--- a/drivers/net/e1000/e1000_hw.h~e1000-if-0-two-functions
+++ a/drivers/net/e1000/e1000_hw.h
@@ -421,8 +421,6 @@ void e1000_tbi_adjust_stats(struct e1000
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
-void e1000_read_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
-void e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value);
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
diff -puN drivers/net/e1000/e1000_main.c~e1000-if-0-two-functions drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~e1000-if-0-two-functions
+++ a/drivers/net/e1000/e1000_main.c
@@ -4890,6 +4890,8 @@ e1000_pci_clear_mwi(struct e1000_hw *hw)
 	pci_clear_mwi(adapter->pdev);
 }
 
+#if 0
+
 void
 e1000_read_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 {
@@ -4906,6 +4908,8 @@ e1000_write_pci_cfg(struct e1000_hw *hw,
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
+#endif  /*  0  */
+
 int
 e1000_pcix_get_mmrbc(struct e1000_hw *hw)
 {
_
