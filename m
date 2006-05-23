From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH] pcnet_cs: Add TRENDnet TE-CF100 ethernet adapter ID
Date: Tue, 23 May 2006 11:15:57 +0200
Message-ID: <200605231115.58969.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:38590 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S932140AbWEWJQE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 05:16:04 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Add TRENDnet TE-CF100 ethernet adapter to pcnet_cs list.

product info: "Fast Ethernet", "CF Size PC Card", "1.0", ""
 manfid: 0x0149, 0xc1ab

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

 drivers/net/pcmcia/pcnet_cs.c |    2 ++
 1 file changed, 2 insertions(+)

Index: netdev-2.6/drivers/net/pcmcia/pcnet_cs.c
===================================================================
--- netdev-2.6.orig/drivers/net/pcmcia/pcnet_cs.c	2006-05-18 11:06:43.294022480 +0200
+++ netdev-2.6/drivers/net/pcmcia/pcnet_cs.c	2006-05-18 11:10:31.548322552 +0200
@@ -1768,6 +1768,8 @@
 	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "NE2K.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "PE-200.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("TAMARACK", "Ethernet", 0xcf434fba, 0x00b2e941, "tamarack.cis"),
+	PCMCIA_DEVICE_PROD_ID123("Fast Ethernet", "CF Size PC Card", "1.0", 
+		0xb4be14e3, 0x43ac239b, 0x0877b627),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, pcnet_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer
