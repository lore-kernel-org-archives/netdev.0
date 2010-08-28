From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.36-rc2] pcnet_cs: add new_id
Date: Sun, 29 Aug 2010 07:45:01 +0900
Message-ID: <20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	<20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:14170 "EHLO
	defg302.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab0H1W5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:57:30 -0400
Received: from userg507.nifty.com (userg507p.nifty.com [172.22.128.87])by defg302.nifty.com with ESMTP id o7SMk2C9011622
	for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 07:46:02 +0900
Received: from localhost.localdomain (eaoska169137.adsl.ppp.infoweb.ne.jp [219.116.18.137])by userg507.nifty.com with SMTP id o7SMjEgs021828
	for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 07:45:14 +0900
In-Reply-To: <20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs:
    add new_id: "KENTRONICS KEP-230" 10Base-T PCMCIA card.


Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.36-rc2/drivers/net/pcmcia/pcnet_cs.c.orig	2010-08-28 09:34:10.000000000 +0900
+++ linux-2.6.36-rc2/drivers/net/pcmcia/pcnet_cs.c	2010-08-28 09:36:53.000000000 +0900
@@ -1637,6 +1637,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_PROD_ID12("IO DATA", "PCETTX", 0x547e66dc, 0x6fc5459b),
 	PCMCIA_DEVICE_PROD_ID12("iPort", "10/100 Ethernet Card", 0x56c538d2, 0x11b0ffc0),
 	PCMCIA_DEVICE_PROD_ID12("KANSAI ELECTRIC CO.,LTD", "KLA-PCM/T", 0xb18dc3b4, 0xcc51a956),
+	PCMCIA_DEVICE_PROD_ID12("KENTRONICS", "KEP-230", 0xaf8144c9, 0x868f6616),
 	PCMCIA_DEVICE_PROD_ID12("KCI", "PE520 PCMCIA Ethernet Adapter", 0xa89b87d3, 0x1eb88e64),
 	PCMCIA_DEVICE_PROD_ID12("KINGMAX", "EN10T2T", 0x7bcb459a, 0xa5c81fa5),
 	PCMCIA_DEVICE_PROD_ID12("Kingston", "KNE-PC2", 0x1128e633, 0xce2a89b3),
