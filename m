From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 4/6] new pcmcia IDs for hostap - PLANEX GW-CF11X
Date: Tue, 16 May 2006 16:21:24 +0200
Message-ID: <200605161621.25399.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:63954 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1751140AbWEPOVx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 10:21:53 -0400
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

---
 drivers/net/wireless/hostap/hostap_cs.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:09:27.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:10:34.000000000 +0200
@@ -929,6 +929,9 @@
 		0x1a424a1c, 0xe78b6dcc),
 	PCMCIA_DEVICE_PROD_ID12("NETGEAR", "MA701 Wireless CF Card",
 		0x9aa79dc3, 0xd9ec98e),
+	PCMCIA_DEVICE_PROD_ID12("PLANEX COMMUNICATION INC", 
+			"PLANEX GW-CF11X Wireless CF Card",
+			0x4703cf68, 0xfad7318d),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

             Today is the first day of the rest of your life.
