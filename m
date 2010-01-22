From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.33-rc5] fmvj18x_cs: add new id (Panasonic lan &
 modem card)
Date: Sat, 23 Jan 2010 06:56:25 +0900
Message-ID: <20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg507.nifty.com ([202.248.238.87]:32416 "EHLO
	userg507.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363Ab0AVV5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 16:57:11 -0500
In-Reply-To: <20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fmvj18x_cs, serial_cs:
 add new id
 Panasonic lan & modem card (model name:AL-VML101)

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.33-rc5/drivers/net/pcmcia/fmvj18x_cs.c.orig	2010-01-22 21:59:25.000000000 +0900
+++ linux-2.6.33-rc5/drivers/net/pcmcia/fmvj18x_cs.c	2010-01-22 21:59:44.000000000 +0900
@@ -717,6 +717,7 @@ static struct pcmcia_device_id fmvj18x_i
 	PCMCIA_PFC_DEVICE_PROD_ID12(0, "NEC", "PK-UG-J001" ,0x18df0ba0 ,0x831b1064),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0105, 0x0d0a),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0105, 0x0e0a),
+	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x0e01),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x0a05),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x0032, 0x1101),
 	PCMCIA_DEVICE_NULL,
--- linux-2.6.33-rc5/drivers/serial/serial_cs.c.orig	2010-01-22 22:00:00.000000000 +0900
+++ linux-2.6.33-rc5/drivers/serial/serial_cs.c	2010-01-22 22:00:21.000000000 +0900
@@ -758,6 +758,7 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "PCMCIAs", "LanModem", 0xdcfe12d3, 0xc67c648f),
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "TDK", "GlobalNetworker 3410/3412", 0x1eae9475, 0xd9a93bed),
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "Xircom", "CreditCard Ethernet+Modem II", 0x2e3ee845, 0xeca401bf),
+	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x0e01),
 	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x0a05),
 	PCMCIA_PFC_DEVICE_MANF_CARD(1, 0x0032, 0x1101),
 	PCMCIA_MFC_DEVICE_MANF_CARD(0, 0x0104, 0x0070),
