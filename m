From: <jie.yang@atheros.com>
Subject: [PATCH]atl1e: remove the unneeded (struct atl1e_adapter *)
Date: Sun, 31 Aug 2008 14:06:41 +0800
Message-ID: <1220162801641-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <matthew@wil.cx>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:39540 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbYHaGGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 02:06:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from Jie Yang <jie.yang@atheros.com>

remove the unneeded (struct atl1e_adapter *), for hw->adapter already 
has type atl1e_adapter *.

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 949e753..8cbc1b5 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -397,7 +397,7 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
  */
 int atl1e_phy_commit(struct atl1e_hw *hw)
 {
-       struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+       struct atl1e_adapter *adapter = hw->adapter;
        struct pci_dev *pdev = adapter->pdev;
        int ret_val;
        u16 phy_data;
@@ -431,7 +431,7 @@ int atl1e_phy_commit(struct atl1e_hw *hw)

 int atl1e_phy_init(struct atl1e_hw *hw)
 {
-       struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+       struct atl1e_adapter *adapter = hw->adapter;
        struct pci_dev *pdev = adapter->pdev;
        s32 ret_val;
        u16 phy_val;
@@ -525,7 +525,7 @@ int atl1e_phy_init(struct atl1e_hw *hw)
  */
 int atl1e_reset_hw(struct atl1e_hw *hw)
 {
-       struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+       struct atl1e_adapter *adapter = hw->adapter;
        struct pci_dev *pdev = adapter->pdev;

