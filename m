From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 02/29] LMC: Remove "lmc_" prefix from source file names.
Date: Sat, 31 Jul 2010 17:05:25 +0200
Message-ID: <1280588752-9340-2-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41124 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab0GaPF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:05:57 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/Makefile                 |    4 ++--
 drivers/net/wan/lmc/{lmc_debug.c =3D> debug.c} |    2 +-
 drivers/net/wan/lmc/{lmc_debug.h =3D> debug.h} |    0
 drivers/net/wan/lmc/{lmc_ioctl.h =3D> ioctl.h} |    0
 drivers/net/wan/lmc/lmc.h                    |    2 +-
 drivers/net/wan/lmc/{lmc_main.c =3D> main.c}   |    8 ++++----
 drivers/net/wan/lmc/{lmc_media.c =3D> media.c} |    6 +++---
 drivers/net/wan/lmc/{lmc_proto.c =3D> proto.c} |    8 ++++----
 drivers/net/wan/lmc/{lmc_proto.h =3D> proto.h} |    0
 drivers/net/wan/lmc/{lmc_var.h =3D> var.h}     |    0
 10 files changed, 15 insertions(+), 15 deletions(-)
 rename drivers/net/wan/lmc/{lmc_debug.c =3D> debug.c} (98%)
 rename drivers/net/wan/lmc/{lmc_debug.h =3D> debug.h} (100%)
 rename drivers/net/wan/lmc/{lmc_ioctl.h =3D> ioctl.h} (100%)
 rename drivers/net/wan/lmc/{lmc_main.c =3D> main.c} (99%)
 rename drivers/net/wan/lmc/{lmc_media.c =3D> media.c} (99%)
 rename drivers/net/wan/lmc/{lmc_proto.c =3D> proto.c} (97%)
 rename drivers/net/wan/lmc/{lmc_proto.h =3D> proto.h} (100%)
 rename drivers/net/wan/lmc/{lmc_var.h =3D> var.h} (100%)

diff --git a/drivers/net/wan/lmc/Makefile b/drivers/net/wan/lmc/Makefil=
e
index dabdcfe..2c14b98 100644
--- a/drivers/net/wan/lmc/Makefile
+++ b/drivers/net/wan/lmc/Makefile
@@ -1,11 +1,11 @@
 #
-# Makefile for the Lan Media 21140 based WAN cards
+# Makefile for the Lan Media/SBE 21140-based WAN cards
 # Specifically the 1000,1200,5200,5245
 #
=20
 obj-$(CONFIG_LANMEDIA) +=3D lmc.o
=20
-lmc-objs :=3D lmc_debug.o lmc_media.o lmc_main.o lmc_proto.o
+lmc-objs :=3D debug.o media.o main.o proto.o
=20
 # Like above except every packet gets echoed to KERN_DEBUG
 # in hex
diff --git a/drivers/net/wan/lmc/lmc_debug.c b/drivers/net/wan/lmc/debu=
g.c
similarity index 98%
rename from drivers/net/wan/lmc/lmc_debug.c
rename to drivers/net/wan/lmc/debug.c
index 35a8610..0abae05 100644
--- a/drivers/net/wan/lmc/lmc_debug.c
+++ b/drivers/net/wan/lmc/debug.c
@@ -1,7 +1,7 @@
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
-#include "lmc_debug.h"
+#include "debug.h"
=20
 /*
  * Prints out len, max to 80 octets using printk, 20 per line
diff --git a/drivers/net/wan/lmc/lmc_debug.h b/drivers/net/wan/lmc/debu=
g.h
similarity index 100%
rename from drivers/net/wan/lmc/lmc_debug.h
rename to drivers/net/wan/lmc/debug.h
diff --git a/drivers/net/wan/lmc/lmc_ioctl.h b/drivers/net/wan/lmc/ioct=
l.h
similarity index 100%
rename from drivers/net/wan/lmc/lmc_ioctl.h
rename to drivers/net/wan/lmc/ioctl.h
diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
index 6d3af03..9742650 100644
--- a/drivers/net/wan/lmc/lmc.h
+++ b/drivers/net/wan/lmc/lmc.h
@@ -1,7 +1,7 @@
 #ifndef _LMC_H_
 #define _LMC_H_
=20
-#include "lmc_var.h"
+#include "var.h"
=20
 int lmc_probe(struct net_device *dev);
 unsigned lmc_mii_readreg(lmc_softc_t * const sc, unsigned
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/main.=
c
similarity index 99%
rename from drivers/net/wan/lmc/lmc_main.c
rename to drivers/net/wan/lmc/main.c
index 3c7f23a..e22aa0c 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -69,10 +69,10 @@
 #define DRIVER_VERSION  ((DRIVER_MAJOR_VERSION << 8) + DRIVER_MINOR_VE=
RSION)
=20
 #include "lmc.h"
-#include "lmc_var.h"
-#include "lmc_ioctl.h"
-#include "lmc_debug.h"
-#include "lmc_proto.h"
+#include "var.h"
+#include "ioctl.h"
+#include "debug.h"
+#include "proto.h"
=20
 static int LMC_PKT_BUF_SZ =3D 1542;
=20
diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/medi=
a.c
similarity index 99%
rename from drivers/net/wan/lmc/lmc_media.c
rename to drivers/net/wan/lmc/media.c
index a3aa2a0..7a545f8 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -17,9 +17,9 @@
 #include <asm/processor.h>   /* Processor type for cache alignment. */
 #include <asm/dma.h>
 #include "lmc.h"
-#include "lmc_var.h"
-#include "lmc_ioctl.h"
-#include "lmc_debug.h"
+#include "var.h"
+#include "ioctl.h"
+#include "debug.h"
=20
 #define CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE 1
=20
diff --git a/drivers/net/wan/lmc/lmc_proto.c b/drivers/net/wan/lmc/prot=
o.c
similarity index 97%
rename from drivers/net/wan/lmc/lmc_proto.c
rename to drivers/net/wan/lmc/proto.c
index ac1fef5..d6c0cc2 100644
--- a/drivers/net/wan/lmc/lmc_proto.c
+++ b/drivers/net/wan/lmc/proto.c
@@ -41,10 +41,10 @@
 #include <linux/smp.h>
=20
 #include "lmc.h"
-#include "lmc_var.h"
-#include "lmc_debug.h"
-#include "lmc_ioctl.h"
-#include "lmc_proto.h"
+#include "var.h"
+#include "debug.h"
+#include "ioctl.h"
+#include "proto.h"
=20
 void lmc_proto_attach(lmc_softc_t *sc)
 {
diff --git a/drivers/net/wan/lmc/lmc_proto.h b/drivers/net/wan/lmc/prot=
o.h
similarity index 100%
rename from drivers/net/wan/lmc/lmc_proto.h
rename to drivers/net/wan/lmc/proto.h
diff --git a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/var.h
similarity index 100%
rename from drivers/net/wan/lmc/lmc_var.h
rename to drivers/net/wan/lmc/var.h
--=20
1.7.1.1

