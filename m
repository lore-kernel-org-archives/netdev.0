From: Olaf Hering <olh@suse.de>
Subject: [PATCH] mark mace and bmac as ppc32 only
Date: Mon, 6 Sep 2004 15:36:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040906133600.GA9143@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


mace and bmac are only used in "oldworld" PowerMacs.
Mark them as ppc32 only.

diff -purN linux-2.6.9-rc1-bk13.orig/drivers/net/Kconfig linux-2.6.9-rc1-=
bk13/drivers/net/Kconfig
--- linux-2.6.9-rc1-bk13.orig/drivers/net/Kconfig	2004-09-06 15:23:35.000=
000000 +0200
+++ linux-2.6.9-rc1-bk13/drivers/net/Kconfig	2004-09-06 15:27:26.29060485=
9 +0200
@@ -200,7 +200,7 @@ source "drivers/net/arm/Kconfig"
=20
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
-	depends on NET_ETHERNET && PPC_PMAC
+	depends on NET_ETHERNET && PPC_PMAC && PPC32
 	select CRC32
 	help
 	  Power Macintoshes and clones with Ethernet built-in on the
@@ -223,7 +223,7 @@ config MACE_AAUI_PORT
=20
 config BMAC
 	tristate "BMAC (G3 ethernet) support"
-	depends on NET_ETHERNET && PPC_PMAC
+	depends on NET_ETHERNET && PPC_PMAC && PPC32
 	select CRC32
 	help
 	  Say Y for support of BMAC Ethernet interfaces. These are used on G3
--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
