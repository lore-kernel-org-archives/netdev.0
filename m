From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.35-rc2] pcnet_cs: add new id (TOSHIBA Modem/LAN
 Card)
Date: Sat, 12 Jun 2010 19:17:28 +0900
Message-ID: <20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:41040 "EHLO
	defg301.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144Ab0FLKa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 06:30:26 -0400
Received: from userg507.nifty.com (userg507p.nifty.com [172.22.128.87])by defg301.nifty.com with ESMTP id o5CAIWlK031768
	for <netdev@vger.kernel.org>; Sat, 12 Jun 2010 19:18:32 +0900
Received: from localhost.localdomain (eaoska325076.adsl.ppp.infoweb.ne.jp [115.176.54.76])by userg507.nifty.com with SMTP id o5CAHwZa002188
	for <netdev@vger.kernel.org>; Sat, 12 Jun 2010 19:17:58 +0900
In-Reply-To: <20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs:
serial_cs:
    add new id (TOSHIBA Modem/LAN Card)

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.35-rc2/drivers/net/pcmcia/pcnet_cs.c.orig	2010-06-12 08:19:26.000000000 +0900
+++ linux-2.6.35-rc2/drivers/net/pcmcia/pcnet_cs.c	2010-06-12 08:21:35.000000000 +0900
@@ -1727,6 +1727,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "TOSHIBA", "Modem/LAN Card", 0xb4585a1a, 0x53f922f8, "cis/PCMLM28.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(0, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "cis/DP83903.cis"),
--- linux-2.6.35-rc2/drivers/serial/serial_cs.c.orig	2010-06-12 09:08:11.000000000 +0900
+++ linux-2.6.35-rc2/drivers/serial/serial_cs.c	2010-06-12 09:08:47.000000000 +0900
@@ -821,6 +821,7 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "TOSHIBA", "Modem/LAN Card", 0xb4585a1a, 0x53f922f8, "cis/PCMLM28.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(1, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(1, "NSC MF LAN/Modem", 0x58fc6056, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0556, "cis/3CCFEM556.cis"),
