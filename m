From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 5/5] new pcmcia IDs for hostap - Planex GW-CF11X
Date: Fri, 12 May 2006 15:52:17 +0200
Message-ID: <200605121552.18112.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:50118 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S932077AbWELNwW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 09:52:22 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Platform: Sharp Zaurus SL-C3100 running 2.6.16 + pcmciautils 013

root@spitz:~# pccardctl ident
Socket 0:
  product info: "HITACHI", "microdrive", "", ""
  manfid: 0x0319, 0x0000
  function: 4 (fixed disk)
Socket 1:
  product info:"PLANEX COMMUNICATION INC","PLANEX GW-CF11X Wireless CF Card", "", ""
  manfid: 0xd601, 0x0010
  function: 6 ( network )

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:46:35.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-12 15:48:54.000000000 +0200
@@ -967,6 +967,9 @@
 				0x4ac44287, 0x235a6bed),
 	PCMCIA_DEVICE_PROD_ID12("PLANEX", "GeoWave/GW-CF110",
 				0x209f40ab, 0xd9715264),
+	PCMCIA_DEVICE_PROD_ID12("PLANEX COMMUNICATION INC", 
+				"PLANEX GW-CF11X Wireless CF Card",
+				0x4703cf68, 0xfad7318d),
 	PCMCIA_DEVICE_PROD_ID12("PLANEX", "GeoWave/GW-NS110",
 				0x209f40ab, 0x46263178),
 	PCMCIA_DEVICE_PROD_ID12(

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

            That must be wonderful! I don understand it at all.
