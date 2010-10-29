From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.36-git10] pcnet_cs: add new_id
Date: Sat, 30 Oct 2010 07:17:51 +0900
Message-ID: <20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
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
	<20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:11197 "EHLO
	defg303.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933111Ab0J2Wd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 18:33:26 -0400
Received: from userg506.nifty.com (userg506p.nifty.com [172.22.128.86])by defg303.nifty.com with ESMTP id o9TMJFrB012354
	for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 07:19:19 +0900
Received: from localhost.localdomain (eaoska041105.adsl.ppp.infoweb.ne.jp [218.217.209.105])by userg506.nifty.com with SMTP id o9TMIhCj006560
	for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 07:18:43 +0900
In-Reply-To: <20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs:
    add new_id: "corega Ether CF-TD" 10Base-T PCMCIA card.


Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.36-git10/drivers/net/pcmcia/pcnet_cs.c.orig	2010-10-29 22:11:43.000000000 +0900
+++ linux-2.6.36-git10/drivers/net/pcmcia/pcnet_cs.c	2010-10-29 22:15:30.000000000 +0900
@@ -1536,6 +1536,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_PROD_ID12("COMPU-SHACK", "FASTline PCMCIA 10/100 Fast-Ethernet", 0xfa2e424d, 0x3953d9b9),
 	PCMCIA_DEVICE_PROD_ID12("CONTEC", "C-NET(PC)C-10L", 0x21cab552, 0xf6f90722),
 	PCMCIA_DEVICE_PROD_ID12("corega", "FEther PCC-TXF", 0x0a21501a, 0xa51564a2),
+	PCMCIA_DEVICE_PROD_ID12("corega", "Ether CF-TD", 0x0a21501a, 0x6589340a),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega EtherII PCC-T", 0x5261440f, 0xfa9d85bd),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "corega EtherII PCC-TD", 0x5261440f, 0xc49bd73d),
 	PCMCIA_DEVICE_PROD_ID12("Corega K.K.", "corega EtherII PCC-TD", 0xd4fdcbd8, 0xc49bd73d),
