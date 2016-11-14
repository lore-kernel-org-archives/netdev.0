From: ho.jia.jie@intel.com
Subject: [PATCH] net: ethernet: Fix SGMII unable to switch speed and autonego failure
Date: Mon, 14 Nov 2016 17:06:49 +0800
Message-ID: <1479114409-20002-1-git-send-email-ho.jia.jie@intel.com>
Cc: Jia Jie Ho <ho.jia.jie@intel.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26241 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752478AbcKNJGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 04:06:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia Jie Ho <ho.jia.jie@intel.com>

TSE PCS SGMII ethernet has an issue where switching speed doesn't work
caused by a faulty register macro offset. This fixes the issue.

Signed-off-by: Jia Jie Ho <ho.jia.jie@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
index 2920e2e..489ef14 100644
--- a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
@@ -63,8 +63,8 @@
 #define TSE_PCS_SGMII_LINK_TIMER_0			0x0D40
 #define TSE_PCS_SGMII_LINK_TIMER_1			0x0003
 #define TSE_PCS_SW_RESET_TIMEOUT			100
-#define TSE_PCS_USE_SGMII_AN_MASK			BIT(2)
-#define TSE_PCS_USE_SGMII_ENA				BIT(1)
+#define TSE_PCS_USE_SGMII_AN_MASK			BIT(1)
+#define TSE_PCS_USE_SGMII_ENA				BIT(0)
 
 #define SGMII_ADAPTER_CTRL_REG				0x00
 #define SGMII_ADAPTER_DISABLE				0x0001
-- 
1.8.2.1
