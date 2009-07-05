From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] pcnet_cs: add new id
Date: Sun, 5 Jul 2009 09:17:10 +0900
Message-ID: <20090705091710.e8b9dc74.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:21743 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbZGEARb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 20:17:31 -0400
Received: from localhost.localdomain (eaoska141023.adsl.ppp.infoweb.ne.jp [219.104.14.23])by userg502.nifty.com with SMTP id n650HIHu011490
	for <netdev@vger.kernel.org>; Sun, 5 Jul 2009 09:17:18 +0900
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


add new id (RIOS System PC CARD3 ETHERNET).

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.31-rc1/drivers/net/pcmcia/pcnet_cs.c.orig	2009-06-27 10:15:47.000000000 +0900
+++ linux-2.6.31-rc1/drivers/net/pcmcia/pcnet_cs.c	2009-07-04 14:19:21.000000000 +0900
@@ -1727,6 +1727,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_PROD_ID12("PRETEC", "Ethernet CompactLAN 10BaseT 3.3V", 0xebf91155, 0x7f5a4f50),
 	PCMCIA_DEVICE_PROD_ID12("Psion Dacom", "Gold Card Ethernet", 0xf5f025c2, 0x3a30e110),
 	PCMCIA_DEVICE_PROD_ID12("=RELIA==", "Ethernet", 0xcdd0644a, 0x00b2e941),
+	PCMCIA_DEVICE_PROD_ID12("RIOS Systems Co.", "PC CARD3 ETHERNET", 0x7dd33481, 0x10b41826),
 	PCMCIA_DEVICE_PROD_ID12("RP", "1625B Ethernet NE2000 Compatible", 0xe3e66e22, 0xb96150df),
 	PCMCIA_DEVICE_PROD_ID12("RPTI", "EP400 Ethernet NE2000 Compatible", 0xdc6f88fd, 0x4a7e2ae0),
 	PCMCIA_DEVICE_PROD_ID12("RPTI", "EP401 Ethernet NE2000 Compatible", 0xdc6f88fd, 0x4bcbd7fd),
