From: Ken Kawasaki <ken_kawasaki@nifty.com>
Subject: [PATCH] pcnet_cs: add new id
Date: Thu, 11 Feb 2016 20:27:04 +0900
Message-ID: <20160211202704.50796b8e353205dfdd8b7959@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from conuserg011.nifty.com ([202.248.44.37]:43631 "EHLO
	conuserg011-v.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751236AbcBKL1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 06:27:12 -0500
Received: from localhost.localdomain (49.253.223.69.eo.eaccess.ne.jp [49.253.223.69]) (authenticated)
	by conuserg011-v.nifty.com with ESMTP id u1BBR5in023601
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 20:27:05 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


add new id (CONTEC C-NET(PC)C-100TX2)

Signed-off-by: Ken Kawasaki <ken_kawasaki@nifty.com>

---

--- linux-4.4.1/drivers/net/ethernet/8390/pcnet_cs.c.orig	2016-02-11 19:26:02.281108472 +0900
+++ linux-4.4.1/drivers/net/ethernet/8390/pcnet_cs.c	2016-02-11 19:27:21.353595301 +0900
@@ -1501,6 +1501,7 @@ static const struct pcmcia_device_id pcn
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x030a),
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1103),
 	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1121),
+	PCMCIA_DEVICE_MANF_CARD(0xc001, 0x0009),
 	PCMCIA_DEVICE_PROD_ID12("2408LAN", "Ethernet", 0x352fff7f, 0x00b2e941),
 	PCMCIA_DEVICE_PROD_ID1234("Socket", "CF 10/100 Ethernet Card", "Revision B", "05/11/06", 0xb38bcc2e, 0x4de88352, 0xeaca6c8d, 0x7e57c22e),
 	PCMCIA_DEVICE_PROD_ID123("Cardwell", "PCMCIA", "ETHERNET", 0x9533672e, 0x281f1c5d, 0x3ff7175b),
