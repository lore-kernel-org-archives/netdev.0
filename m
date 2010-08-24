From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: update PCI ids
Date: Mon, 23 Aug 2010 20:21:01 -0700
Message-ID: <1282620061-32608-5-git-send-email-dm@chelsio.com>
References: <1282620061-32608-1-git-send-email-dm@chelsio.com>
 <1282620061-32608-2-git-send-email-dm@chelsio.com>
 <1282620061-32608-3-git-send-email-dm@chelsio.com>
 <1282620061-32608-4-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23520 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab0HXD2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:28:21 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o7O3SLMC022367
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 20:28:21 -0700
In-Reply-To: <1282620061-32608-4-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index cadf334..7f1f65b 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -175,16 +175,26 @@ enum {
 
 static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0xa000, 0),  /* PE10K */
-	CH_DEVICE(0x4001, 0),
-	CH_DEVICE(0x4002, 0),
-	CH_DEVICE(0x4003, 0),
-	CH_DEVICE(0x4004, 0),
-	CH_DEVICE(0x4005, 0),
-	CH_DEVICE(0x4006, 0),
-	CH_DEVICE(0x4007, 0),
-	CH_DEVICE(0x4008, 0),
-	CH_DEVICE(0x4009, 0),
-	CH_DEVICE(0x400a, 0),
+	CH_DEVICE(0x4001, -1),
+	CH_DEVICE(0x4002, -1),
+	CH_DEVICE(0x4003, -1),
+	CH_DEVICE(0x4004, -1),
+	CH_DEVICE(0x4005, -1),
+	CH_DEVICE(0x4006, -1),
+	CH_DEVICE(0x4007, -1),
+	CH_DEVICE(0x4008, -1),
+	CH_DEVICE(0x4009, -1),
+	CH_DEVICE(0x400a, -1),
+	CH_DEVICE(0x4401, 4),
+	CH_DEVICE(0x4402, 4),
+	CH_DEVICE(0x4403, 4),
+	CH_DEVICE(0x4404, 4),
+	CH_DEVICE(0x4405, 4),
+	CH_DEVICE(0x4406, 4),
+	CH_DEVICE(0x4407, 4),
+	CH_DEVICE(0x4408, 4),
+	CH_DEVICE(0x4409, 4),
+	CH_DEVICE(0x440a, 4),
 	{ 0, }
 };
 
-- 
1.5.4

