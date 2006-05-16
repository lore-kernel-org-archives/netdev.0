From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 6/6] new pcmcia IDs for hostap - U.S. Robotics
Date: Tue, 16 May 2006 16:21:30 +0200
Message-ID: <200605161621.31516.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:723 "EHLO smtp.host4.kei.pl")
	by vger.kernel.org with ESMTP id S1751143AbWEPOVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 10:21:54 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jochen Friedrich <jochen@scram.de>

Yet another card known to work OK with hostap_cs:

# pccardctl ident
Socket 0:
  no product info available
Socket 1:
  product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
  manfid: 0x0156, 0x0002
  function: 6 (network)

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

---
 drivers/net/wireless/hostap/hostap_cs.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:09:29.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:09:29.000000000 +0200
@@ -935,6 +935,9 @@
 	PCMCIA_DEVICE_PROD_ID123(
 			"Pretec", "CompactWLAN Card 802.11b", "2.5",
 			0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
+	PCMCIA_DEVICE_PROD_ID1234(
+		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
+		0xc7b8df9d, 0x1700d087, 0x4b74baa0, 0x00000000),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

     This may seem a bit weird, but that's okay, because it is weird.
                     -- Perl documentation
