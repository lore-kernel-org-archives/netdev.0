From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 4/4] cxgb4: Update T6 register ranges
Date: Tue,  4 Aug 2015 14:36:20 +0530
Message-ID: <1438679180-25930-5-git-send-email-hariprasad@chelsio.com>
References: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4419 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755169AbbHDDv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 23:51:58 -0400
In-Reply-To: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 5c63ceb..91750ad 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1359,9 +1359,10 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 	};
 
 	static const unsigned int t6_reg_ranges[] = {
-		0x1008, 0x114c,
+		0x1008, 0x1124,
+		0x1138, 0x114c,
 		0x1180, 0x11b4,
-		0x11fc, 0x1250,
+		0x11fc, 0x1254,
 		0x1280, 0x133c,
 		0x1800, 0x18fc,
 		0x3000, 0x302c,
@@ -1384,16 +1385,16 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x5c10, 0x5ec0,
 		0x5ec8, 0x5ecc,
 		0x6000, 0x6040,
-		0x6058, 0x615c,
+		0x6058, 0x619c,
 		0x7700, 0x7798,
 		0x77c0, 0x7880,
 		0x78cc, 0x78fc,
 		0x7b00, 0x7c54,
 		0x7d00, 0x7efc,
-		0x8dc0, 0x8de0,
+		0x8dc0, 0x8de4,
 		0x8df8, 0x8e84,
 		0x8ea0, 0x8f88,
-		0x8fb8, 0x911c,
+		0x8fb8, 0x9124,
 		0x9400, 0x9470,
 		0x9600, 0x971c,
 		0x9800, 0x9808,
@@ -1413,9 +1414,8 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0xdfc0, 0xdfe0,
 		0xe000, 0xf008,
 		0x11000, 0x11014,
-		0x11048, 0x11110,
-		0x11118, 0x1117c,
-		0x11190, 0x11264,
+		0x11048, 0x1117c,
+		0x11190, 0x11270,
 		0x11300, 0x1130c,
 		0x12000, 0x1206c,
 		0x19040, 0x1906c,
@@ -1500,9 +1500,8 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x1ff00, 0x1ff84,
 		0x1ffc0, 0x1ffc8,
 		0x30000, 0x30070,
-		0x30100, 0x3015c,
-		0x30190, 0x301d0,
-		0x30200, 0x30318,
+		0x30100, 0x301d0,
+		0x30200, 0x30320,
 		0x30400, 0x3052c,
 		0x30540, 0x3061c,
 		0x30800, 0x30890,
@@ -1578,9 +1577,8 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x33c24, 0x33c50,
 		0x33cf0, 0x33cfc,
 		0x34000, 0x34070,
-		0x34100, 0x3415c,
-		0x34190, 0x341d0,
-		0x34200, 0x34318,
+		0x34100, 0x341d0,
+		0x34200, 0x34320,
 		0x34400, 0x3452c,
 		0x34540, 0x3461c,
 		0x34800, 0x34890,
-- 
2.3.4
