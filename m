From: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Subject: New card for hostap_cs
Date: Fri, 30 Mar 2007 15:34:14 +0200
Message-ID: <200703301534.17871.openembedded@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>,
	Jean Tourrilhes <jt@hpl.hp.com>, Pavel Roskin <proski@gnu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:55171 "EHLO
	smtp.host4.kei.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbXC3NlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 09:41:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Juszkiewicz <openembedded@hrw.one.pl>

Add ADLINK 345 CF card into hostap_cs

product info: "ADLINK 345 CF"
 manfid 0xd601, 0x0005

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>


Index: git/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- git.orig/drivers/net/wireless/hostap/hostap_cs.c	2007-02-16 
17:10:26.993110019 +0100
+++ git/drivers/net/wireless/hostap/hostap_cs.c	2007-02-16 
17:11:15.241749387 +0100
@@ -838,6 +838,8 @@
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0010),
 	PCMCIA_DEVICE_MANF_CARD(0x0126, 0x0002),
+	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0xd601, 0x0005, "ADLINK 345 CF",
+					 0x2d858104),
 	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0x0156, 0x0002, "INTERSIL",
 					 0x74c5e40d),
 	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0x0156, 0x0002, "Intersil",

-- 
JID: hrw-jabber.org
OpenEmbedded developer


