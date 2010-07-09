From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH v3 2/2] ks8842: Remove unnecessary bank select.
Date: Fri, 09 Jul 2010 08:28:16 +0200
Message-ID: <1278656896.6953.15.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:53186 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab0GIGtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:49:08 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 56351E8FB8
	for <netdev@vger.kernel.org>; Fri,  9 Jul 2010 08:28:17 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an unnecessary bank select before resetting the
controller.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 5191af2..0be9261 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -199,7 +199,6 @@ static void ks8842_reset(struct ks8842_adapter *ada=
pter)
 	msleep(10);
 	iowrite16(0, adapter->hw_addr + REG_GRR);
 	*/
-	iowrite16(32, adapter->hw_addr + REG_SELECT_BANK);
 	iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
 	msleep(20);
 }

