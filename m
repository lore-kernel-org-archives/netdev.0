From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.33] axnet_cs: add new id
Date: Sun, 28 Feb 2010 08:34:20 +0900
Message-ID: <20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:45282 "EHLO
	defg303p.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030902Ab0B0XjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 18:39:22 -0500
Received: from userg508.nifty.com (userg508p.nifty.com [172.22.128.88])by defg303p.nifty.com with ESMTP id o1RNacMY002684
	for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 08:36:38 +0900
Received: from localhost.localdomain (eaoska192127.adsl.ppp.infoweb.ne.jp [220.145.29.127])by userg508.nifty.com with SMTP id o1RNa3Rg022040
	for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 08:36:04 +0900
In-Reply-To: <20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
  add new id (corega PCC-TXM)

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.33-stock/drivers/net/pcmcia/axnet_cs.c.orig	2010-02-27 20:57:19.000000000 +0900
+++ linux-2.6.33-stock/drivers/net/pcmcia/axnet_cs.c	2010-02-27 20:59:27.000000000 +0900
@@ -779,6 +779,7 @@ static struct pcmcia_device_id axnet_ids
 	PCMCIA_DEVICE_PROD_ID12("CNet", "CNF301", 0xbc477dde, 0x78c5f40b),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FEther PCC-TXD", 0x5261440f, 0x436768c5),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FEtherII PCC-TXD", 0x5261440f, 0x730df72e),
+	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega FEther PCC-TXM", 0x5261440f, 0x3abbd061),
 	PCMCIA_DEVICE_PROD_ID12("Dynalink", "L100C16", 0x55632fd5, 0x66bc2a90),
 	PCMCIA_DEVICE_PROD_ID12("IO DATA", "ETXPCM", 0x547e66dc, 0x233adac2),
 	PCMCIA_DEVICE_PROD_ID12("Linksys", "EtherFast 10/100 PC Card (PCMPC100 V3)", 0x0733cc81, 0x232019a8),
