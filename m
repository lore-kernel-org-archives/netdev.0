From: Antonio Ospite <ao2@ao2.it>
Subject: [PATCH 08/12] trivial: net: atl1e: atl1e_hw.h: fix 0x0x prefix
Date: Tue, 28 Apr 2015 13:11:27 +0200
Message-ID: <1430219491-5076-9-git-send-email-ao2@ao2.it>
References: <1430219491-5076-1-git-send-email-ao2@ao2.it>
Cc: Antonio Ospite <ao2@ao2.it>, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp206.alice.it ([82.57.200.102]:21275 "EHLO smtp206.alice.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964921AbbD1LSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 07:18:11 -0400
In-Reply-To: <1430219491-5076-1-git-send-email-ao2@ao2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the 0x0x prefix in an integer constant.

Signed-off-by: Antonio Ospite <ao2@ao2.it>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/atheros/atl1e/atl1e_hw.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_hw.h b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.h
index 74df16a..88a6271 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_hw.h
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.h
@@ -129,7 +129,7 @@ s32 atl1e_restart_autoneg(struct atl1e_hw *hw);
 #define     TWSI_CTRL_LD_SLV_ADDR_SHIFT     8
 #define     TWSI_CTRL_SW_LDSTART            0x800
 #define     TWSI_CTRL_HW_LDSTART            0x1000
-#define     TWSI_CTRL_SMB_SLV_ADDR_MASK     0x0x7F
+#define     TWSI_CTRL_SMB_SLV_ADDR_MASK     0x7F
 #define     TWSI_CTRL_SMB_SLV_ADDR_SHIFT    15
 #define     TWSI_CTRL_LD_EXIST              0x400000
 #define     TWSI_CTRL_READ_FREQ_SEL_MASK    0x3
-- 
2.1.4
