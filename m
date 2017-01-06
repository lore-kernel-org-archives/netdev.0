From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add port description for new cards.
Date: Fri,  6 Jan 2017 16:52:10 +0530
Message-ID: <1483701730-11926-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, hariprasad@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:3888 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754848AbdAFOEg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 09:04:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add port description for 25G and 100G cards, and also
change few port descriptions in compliance with the new
naming convention.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cd5f437..8862fbd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5382,22 +5382,28 @@ unsigned int t4_get_mps_bg_map(struct adapter *adap, int idx)
 const char *t4_get_port_type_description(enum fw_port_type port_type)
 {
 	static const char *const port_type_description[] = {
-		"R XFI",
-		"R XAUI",
-		"T SGMII",
-		"T XFI",
-		"T XAUI",
+		"Fiber_XFI",
+		"Fiber_XAUI",
+		"BT_SGMII",
+		"BT_XFI",
+		"BT_XAUI",
 		"KX4",
 		"CX4",
 		"KX",
 		"KR",
-		"R SFP+",
-		"KR/KX",
-		"KR/KX/KX4",
-		"R QSFP_10G",
-		"R QSA",
-		"R QSFP",
-		"R BP40_BA",
+		"SFP",
+		"BP_AP",
+		"BP4_AP",
+		"QSFP_10G",
+		"QSA",
+		"QSFP",
+		"BP40_BA",
+		"KR4_100G",
+		"CR4_QSFP",
+		"CR_QSFP",
+		"CR2_QSFP",
+		"SFP28",
+		"KR_SFP28",
 	};
 
 	if (port_type < ARRAY_SIZE(port_type_description))
-- 
2.1.0
