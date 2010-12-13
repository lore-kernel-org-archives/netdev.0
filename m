From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.37-rc5] axnet_cs: move id (0x1bf, 0x2328) to
 axnet_cs
Date: Mon, 13 Dec 2010 21:27:24 +0900
Message-ID: <20101213212724.353e84f1.ken_kawasaki@spring.nifty.jp>
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
	<20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
	<20101114084208.b3ee991d.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg508.nifty.com ([202.248.238.88]:36875 "EHLO
	userg508.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754Ab0LMM2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 07:28:04 -0500
Received: from localhost.localdomain (eaoska324058.adsl.ppp.infoweb.ne.jp [115.176.53.58])by userg508.nifty.com with SMTP id oBDCRq7f029513
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 21:27:52 +0900
In-Reply-To: <20101114084208.b3ee991d.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
    Accton EN2328 or compatible (id: 0x01bf, 0x2328) uses Asix chip.
    So it works better with axnet_cs instead of pcnet_cs.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.37-rc5/drivers/net/pcmcia/axnet_cs.c.orig	2010-12-12 17:26:37.000000000 +0900
+++ linux-2.6.37-rc5/drivers/net/pcmcia/axnet_cs.c	2010-12-12 17:27:22.000000000 +0900
@@ -690,6 +690,7 @@ static void block_output(struct net_devi
 static struct pcmcia_device_id axnet_ids[] = {
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x016c, 0x0081),
 	PCMCIA_DEVICE_MANF_CARD(0x018a, 0x0301),
+	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x2328),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0301),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0303),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0309),
--- linux-2.6.37-rc5/drivers/net/pcmcia/pcnet_cs.c.orig	2010-12-12 17:26:31.000000000 +0900
+++ linux-2.6.37-rc5/drivers/net/pcmcia/pcnet_cs.c	2010-12-12 17:26:58.000000000 +0900
@@ -1493,7 +1493,6 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_MANF_CARD(0x0149, 0x4530),
 	PCMCIA_DEVICE_MANF_CARD(0x0149, 0xc1ab),
 	PCMCIA_DEVICE_MANF_CARD(0x0186, 0x0110),
-	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x2328),
 	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x8041),
 	PCMCIA_DEVICE_MANF_CARD(0x0213, 0x2452),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0300),
