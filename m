From: Olaf Hering <olh@suse.de>
Subject: [PATCH] remove old version check from mac8390
Date: Sat, 21 Aug 2004 17:49:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821154906.GA14498@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This 'netdevice' define will end up in the 'tags' file.
Its not used, so just remove it.


diff -p -purN linux-2.6.8.1.kaputt/drivers/net/mac8390.c linux-2.6.8.1/dr=
ivers/net/mac8390.c
--- linux-2.6.8.1.kaputt/drivers/net/mac8390.c	2004-08-14 12:55:33.000000=
000 +0200
+++ linux-2.6.8.1/drivers/net/mac8390.c	2004-08-21 17:45:12.000000000 +02=
00
@@ -42,10 +42,6 @@
=20
 #include "8390.h"
=20
-#if (LINUX_VERSION_CODE < 0x02030e)
-#define net_device device
-#endif
-
 #define WD_START_PG			0x00	/* First page of TX buffer */
 #define CABLETRON_RX_START_PG		0x00    /* First page of RX buffer */
 #define CABLETRON_RX_STOP_PG		0x30    /* Last page +1 of RX ring */
--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
