From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.38-rc5] fmvj18x_cs: add new id
Date: Mon, 21 Feb 2011 00:07:20 +0900
Message-ID: <20110221000720.e93225c1.ken_kawasaki@spring.nifty.jp>
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
	<20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20110111205558.98fcab01.ken_kawasaki@spring.nifty.jp>
	<20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg507.nifty.com ([202.248.238.87]:46521 "EHLO
	userg507.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000Ab1BTPIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 10:08:17 -0500
Received: from localhost.localdomain (eaoska140105.adsl.ppp.infoweb.ne.jp [219.104.13.105])by userg507.nifty.com with SMTP id p1KF8D7U008241
	for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 00:08:13 +0900
In-Reply-To: <20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fmvj18x_cs:add new id
           Toshiba lan&modem multifuction card (model name:IPC5010A)

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.38-rc5/drivers/net/pcmcia/fmvj18x_cs.c.orig	2011-02-20 14:04:06.000000000 +0900
+++ linux-2.6.38-rc5/drivers/net/pcmcia/fmvj18x_cs.c	2011-02-20 14:04:21.000000000 +0900
@@ -691,6 +691,7 @@ static struct pcmcia_device_id fmvj18x_i
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0105, 0x0e0a),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x0e01),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x0a05),
+	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x0b05),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x1101),
 	PCMCIA_DEVICE_NULL,
 };
--- linux-2.6.38-rc5/drivers/tty/serial/serial_cs.c.orig	2011-02-20 14:05:09.000000000 +0900
+++ linux-2.6.38-rc5/drivers/tty/serial/serial_cs.c	2011-02-20 14:05:28.000000000 +0900
@@ -712,6 +712,7 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "Xircom", "CreditCard Ethernet+Modem II", 0x2e3ee845, 0xeca401bf),
 	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x0e01),
 	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x0a05),
+	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x0b05),
 	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x1101),
 	PCMCIA_MFC_DEVICE_MANF_CARD(0, 0x0104, 0x0070),
 	PCMCIA_MFC_DEVICE_MANF_CARD(1, 0x0101, 0x0562),

