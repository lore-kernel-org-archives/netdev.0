From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4: Update register ranges for T6 adapter
Date: Tue,  7 Jul 2015 21:49:19 +0530
Message-ID: <1436285961-8674-3-git-send-email-hariprasad@chelsio.com>
References: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16199 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755502AbbGGLFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:05:33 -0400
In-Reply-To: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 2b52aae..ba2be1e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1345,9 +1345,9 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x5a80, 0x5a9c,
 		0x5b94, 0x5bfc,
 		0x5c10, 0x5ec0,
-		0x5ec8, 0x5ec8,
+		0x5ec8, 0x5ecc,
 		0x6000, 0x6040,
-		0x6058, 0x6154,
+		0x6058, 0x615c,
 		0x7700, 0x7798,
 		0x77c0, 0x7880,
 		0x78cc, 0x78fc,
@@ -1371,20 +1371,22 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x9f00, 0x9f6c,
 		0x9f80, 0xa020,
 		0xd004, 0xd03c,
+		0xd100, 0xd118,
+		0xd200, 0xd31c,
 		0xdfc0, 0xdfe0,
 		0xe000, 0xf008,
 		0x11000, 0x11014,
 		0x11048, 0x11110,
 		0x11118, 0x1117c,
-		0x11190, 0x11260,
+		0x11190, 0x11264,
 		0x11300, 0x1130c,
-		0x12000, 0x1205c,
+		0x12000, 0x1206c,
 		0x19040, 0x1906c,
 		0x19078, 0x19080,
 		0x1908c, 0x19124,
 		0x19150, 0x191b0,
 		0x191d0, 0x191e8,
-		0x19238, 0x192b8,
+		0x19238, 0x192bc,
 		0x193f8, 0x19474,
 		0x19490, 0x194cc,
 		0x194f0, 0x194f8,
@@ -1466,7 +1468,7 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x30200, 0x30318,
 		0x30400, 0x3052c,
 		0x30540, 0x3061c,
-		0x30800, 0x3088c,
+		0x30800, 0x30890,
 		0x308c0, 0x30908,
 		0x30910, 0x309b8,
 		0x30a00, 0x30a04,
@@ -1544,7 +1546,7 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x34200, 0x34318,
 		0x34400, 0x3452c,
 		0x34540, 0x3461c,
-		0x34800, 0x3488c,
+		0x34800, 0x34890,
 		0x348c0, 0x34908,
 		0x34910, 0x349b8,
 		0x34a00, 0x34a04,
-- 
2.3.4
