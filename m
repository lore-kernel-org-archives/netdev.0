From: Christian Steineck <Christian.Steineck@web.de>
Subject: [patch 1/2] hostap_cs: added support for Proxim Harmony PCI W-Lan
 card
Date: Fri, 08 Sep 2006 23:51:34 +0200
Message-ID: <4501E5E6.8090705@web.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010206090604060705040101"
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:51615 "EHLO
	fmmailgate03.web.de") by vger.kernel.org with ESMTP
	id S1751211AbWIHVqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 17:46:19 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010206090604060705040101
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

hostap_cs driver
- added support for Proxim Harmony PCI W-Lan Card (uses pd6729 based
pcmcia2pci bridge)

Signed-off-by: Christian Steineck <memphis@machzwo.de>

^---

This is my first patch, if the form of delivery is not as it should be
please forgive me :o)

best regards

Christian

--------------010206090604060705040101
Content-Type: text/plain;
 name="hostap_cs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hostap_cs.patch"

--- drivers/net/wireless/hostap/hostap_cs.orig	2006-09-08 17:53:42.000000000 +0200
+++ drivers/net/wireless/hostap/hostap_cs.c	2006-09-08 22:37:14.000000000 +0200
@@ -848,6 +848,7 @@
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0010),
+	PCMCIA_DEVICE_MANF_CARD(0x0126, 0x0002),	
 	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0x0156, 0x0002, "INTERSIL",
 					 0x74c5e40d),
 	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0x0156, 0x0002, "Intersil",

--------------010206090604060705040101--
