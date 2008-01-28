From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 1/1] replace logical- by bit-or in smctr_make_tx_status_code(),
 drivers/net/tokenring/smctr.c
Date: Mon, 28 Jan 2008 11:54:07 +0100
Message-ID: <479DB44F.1050506@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mikep@linuxtr.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:46082 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbYA1KyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 05:54:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/tokenring/smctr.h:50:#define      IBM_PASS_SOURCE_ADDR    0x01
--
replace logical- by bit-or for IBM_PASS_SOURCE_ADDR

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 93da3a3..ec29766 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3413,7 +3413,7 @@ static int smctr_make_tx_status_code(struct net_device *dev,
         tsv->svi = TRANSMIT_STATUS_CODE;
         tsv->svl = S_TRANSMIT_STATUS_CODE;
 
-        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);
+        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) | IBM_PASS_SOURCE_ADDR);
 
         /* Stripped frame status of Transmitted Frame */
         tsv->svv[1] = tx_fstatus & 0xff;
