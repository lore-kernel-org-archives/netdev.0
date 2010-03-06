From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] MAINTAINER: Correct CAN Maintainer responsibilities and paths
Date: Sat, 06 Mar 2010 18:31:50 +0000
Message-ID: <4B929F96.1030402@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: Wolfgang Grandegger <wg@grandegger.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:50538 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab0CFRc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 12:32:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the CAN Maintainer responsibilities and add source paths.
Additional the SocketCAN core ML is not subscribers-only anymore.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/MAINTAINERS b/MAINTAINERS
index 34f52a1..9ee1f78 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1372,20 +1372,28 @@ F:	arch/x86/include/asm/calgary.h
 F:	arch/x86/include/asm/tce.h

 CAN NETWORK LAYER
-M:	Urs Thuermann <urs.thuermann@volkswagen.de>
+M:	Oliver Hartkopp <socketcan@hartkopp.net>
 M:	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
-L:	socketcan-core@lists.berlios.de (subscribers-only)
+M:	Urs Thuermann <urs.thuermann@volkswagen.de>
+L:	socketcan-core@lists.berlios.de
 W:	http://developer.berlios.de/projects/socketcan/
 S:	Maintained
-F:	drivers/net/can/
-F:	include/linux/can/
+F:	net/can/
 F:	include/linux/can.h
+F:	include/linux/can/core.h
+F:	include/linux/can/bcm.h
+F:	include/linux/can/raw.h

 CAN NETWORK DRIVERS
 M:	Wolfgang Grandegger <wg@grandegger.com>
-L:	socketcan-core@lists.berlios.de (subscribers-only)
+L:	socketcan-core@lists.berlios.de
 W:	http://developer.berlios.de/projects/socketcan/
 S:	Maintained
+F:	drivers/net/can/
+F:	include/linux/can/dev.h
+F:	include/linux/can/error.h
+F:	include/linux/can/netlink.h
+F:	include/linux/can/platform/

 CELL BROADBAND ENGINE ARCHITECTURE
 M:	Arnd Bergmann <arnd@arndb.de>
