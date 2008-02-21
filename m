From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/7] e1000e: remove unused read value in ASPM disable code.
Date: Thu, 21 Feb 2008 15:11:13 -0800
Message-ID: <20080221231113.5595.11336.stgit@localhost.localdomain>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42144 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755969AbYBUXMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 18:12:38 -0500
In-Reply-To: <20080221231041.5595.4933.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 7824bc2..fc5c63f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3490,7 +3490,6 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 static void e1000e_disable_l1aspm(struct pci_dev *pdev)
 {
 	int pos;
-	u32 cap;
 	u16 val;
 
 	/*
@@ -3505,7 +3504,6 @@ static void e1000e_disable_l1aspm(struct pci_dev *pdev)
 	 * active.
 	 */
 	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	pci_read_config_dword(pdev, pos + PCI_EXP_LNKCAP, &cap);
 	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
 	if (val & 0x2) {
 		dev_warn(&pdev->dev, "Disabling L1 ASPM\n");

