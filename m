From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: [PATCH 5/6] new pcmcia IDs for hostap - Pretec
Date: Tue, 16 May 2006 16:21:28 +0200
Message-ID: <200605161621.29026.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:65234 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S1751142AbWEPOVx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 10:21:53 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I use two Zaurus palmtops - one run 2.4.18 kernel (it's sl-5500) and second 
run 2.6.16. Both are running under control of OpenZaurus distribution 
(I'm Release Manager of it).

When I use pcmcia-cs then my Pretec WiFi card is handled by hostap driver
and everything is working fine. Recently I switched to pcmciautils and after
card insert orinoco modules are loaded. I prefer to use hostap modules
because they work the same under 2.4 and 2.6 kernels (with orinoco I have to
use 0.13e ones because never ones does not work under 2.4/arm).

This patch adds definition of my card to hostap_cs cardlist. It was tested on
Sharp Zaurus C760 palmtop running 2.6.16 + pcmciautils 010 + udev 084

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

---
 drivers/net/wireless/hostap/hostap_cs.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:09:28.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:10:32.000000000 +0200
@@ -932,6 +932,9 @@
 	PCMCIA_DEVICE_PROD_ID12("PLANEX COMMUNICATION INC", 
 			"PLANEX GW-CF11X Wireless CF Card",
 			0x4703cf68, 0xfad7318d),
+	PCMCIA_DEVICE_PROD_ID123(
+			"Pretec", "CompactWLAN Card 802.11b", "2.5",
+			0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);

-- 
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

         You can close your eyes to reality, but not to memories.
