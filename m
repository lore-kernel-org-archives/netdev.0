From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some warnings on Blackfin
Date: Mon, 13 Oct 2008 17:10:09 +0800
Message-ID: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Javier Herrero <jherrero@hvsistemas.es>,
	Bryan Wu <cooloney@kernel.org>
To: ben@simtec.co.uk, s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:12972 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbYJMJJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 05:09:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Herrero <jherrero@hvsistemas.es>

Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/dm9000.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index f42c23f..c4737ca 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -188,35 +188,35 @@ iow(board_info_t * db, int reg, int value)
 
 static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
 {
-	writesb(reg, data, count);
+	writesb((int)reg, data, count);
 }
 
 static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
 {
-	writesw(reg, data, (count+1) >> 1);
+	writesw((int)reg, data, (count+1) >> 1);
 }
 
 static void dm9000_outblk_32bit(void __iomem *reg, void *data, int count)
 {
-	writesl(reg, data, (count+3) >> 2);
+	writesl((int)reg, data, (count+3) >> 2);
 }
 
 /* input block from chip to memory */
 
 static void dm9000_inblk_8bit(void __iomem *reg, void *data, int count)
 {
-	readsb(reg, data, count);
+	readsb((int)reg, data, count);
 }
 
 
 static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
 {
-	readsw(reg, data, (count+1) >> 1);
+	readsw((int)reg, data, (count+1) >> 1);
 }
 
 static void dm9000_inblk_32bit(void __iomem *reg, void *data, int count)
 {
-	readsl(reg, data, (count+3) >> 2);
+	readsl((int)reg, data, (count+3) >> 2);
 }
 
 /* dump block from chip to null */
-- 
1.5.6
