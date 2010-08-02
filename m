From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/9] cxgb4: disable an interrupt that is neither used nor serviced
Date: Mon,  2 Aug 2010 16:19:16 -0700
Message-ID: <1280791164-14181-2-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19026 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJO6a025623
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:24 -0700
In-Reply-To: <1280791164-14181-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index ab46797..9e1a4b4 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -1444,7 +1444,7 @@ static void pl_intr_handler(struct adapter *adap)
 		t4_fatal_err(adap);
 }
 
-#define PF_INTR_MASK (PFSW | PFCIM)
+#define PF_INTR_MASK (PFSW)
 #define GLBL_INTR_MASK (CIM | MPS | PL | PCIE | MC | EDC0 | \
 		EDC1 | LE | TP | MA | PM_TX | PM_RX | ULP_RX | \
 		CPL_SWITCH | SGE | ULP_TX)
-- 
1.5.4

