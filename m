From: Christian Steineck <Christian.Steineck@web.de>
Subject: [patch 2/2] hostap_cs.mod: generating proper entry in /lib/<kernelversion>/modules.alias
 for Proxim Harmony PCI W-Lan card
Date: Fri, 08 Sep 2006 23:51:36 +0200
Message-ID: <4501E5E8.7050407@web.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090509050002080106000902"
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:51917 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP
	id S1751220AbWIHVqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 17:46:43 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090509050002080106000902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

hostap_cs driver
- added proper entry in /lib/<kernelversion>/modules.alias for Proxim
Harmony PCI W-Lan Card (uses pd6729 based pcmcia2pci bridge)

Signed-off-by: Christian Steineck <memphis@machzwo.de>

^---

This is my first patch, if the form of delivery is not as it should be
please forgive me :o)


best regards

Christian

--------------090509050002080106000902
Content-Type: text/plain;
 name="hostap_cs.mod.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hostap_cs.mod.patch"

--- drivers/net/wireless/hostap/hostap_cs.mod.c.orig	2006-09-08 22:39:32.000000000 +0200
+++ drivers/net/wireless/hostap/hostap_cs.mod.c	2006-09-08 23:27:23.000000000 +0200
@@ -50,5 +50,6 @@
 MODULE_ALIAS("pcmcia:m*c*f*fn*pfn*pa74C5E40DpbDB472A18pc*pd*");
 MODULE_ALIAS("pcmcia:m*c*f*fn*pfn*pa0733CC81pb0C52F395pc*pd*");
 MODULE_ALIAS("pcmcia:m*c*f*fn*pfn*pa273FE3DBpb32A1EAEEpc*pd*");
+MODULE_ALIAS("pcmcia:m0126c0002f06fn00pfn00paC6536A5Epb9F494E26pc00000000pd00000000");
 
 MODULE_INFO(srcversion, "6D6E7A7655C37028DF40116");

--------------090509050002080106000902--
