From: akpm@linux-foundation.org
Subject: [patch 16/21] atl1e: remove the unneeded (struct atl1e_adapter *)
Date: Mon, 22 Sep 2008 14:52:25 -0700
Message-ID: <200809222152.m8MLqPYL031984@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jie.yang@atheros.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55569 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbYIVV4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:56:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

Remove the unneeded (struct atl1e_adapter *) casts, for hw->adapter
already has type atl1e_adapter *.

Signed-off-by: Jie Yang <jie.yang@atheros.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/atl1e/atl1e_hw.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/atl1e/atl1e_hw.c~atl1e-remove-the-unneeded-struct-atl1e_adapter drivers/net/atl1e/atl1e_hw.c
--- a/drivers/net/atl1e/atl1e_hw.c~atl1e-remove-the-unneeded-struct-atl1e_adapter
+++ a/drivers/net/atl1e/atl1e_hw.c
@@ -397,7 +397,7 @@ static int atl1e_phy_setup_autoneg_adv(s
  */
 int atl1e_phy_commit(struct atl1e_hw *hw)
 {
-	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+	struct atl1e_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	int ret_val;
 	u16 phy_data;
@@ -431,7 +431,7 @@ int atl1e_phy_commit(struct atl1e_hw *hw
 
 int atl1e_phy_init(struct atl1e_hw *hw)
 {
-	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+	struct atl1e_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 	s32 ret_val;
 	u16 phy_val;
@@ -525,7 +525,7 @@ int atl1e_phy_init(struct atl1e_hw *hw)
  */
 int atl1e_reset_hw(struct atl1e_hw *hw)
 {
-	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+	struct atl1e_adapter *adapter = hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
 
 	u32 idle_status_data = 0;
_
