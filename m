From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 11/27] drivers/net/igb: remove dead code (function
	'igb_read_pci_cfg')
Date: Mon, 22 Dec 2008 20:16:32 +0100
Message-ID: <20081222191632.11807.3776.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:29685 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbYLVTQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:16:39 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this warning:

  drivers/net/igb/e1000_mac.c:54: warning: 'igb_read_pci_cfg' defined but not used

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/igb/e1000_mac.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 137269d..97f0049 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -50,13 +50,6 @@ void igb_remove_device(struct e1000_hw *hw)
 	kfree(hw->dev_spec);
 }
 
-static void igb_read_pci_cfg(struct e1000_hw *hw, u32 reg, u16 *value)
-{
-	struct igb_adapter *adapter = hw->back;
-
-	pci_read_config_word(adapter->pdev, reg, value);
-}
-
 static s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 {
 	struct igb_adapter *adapter = hw->back;

