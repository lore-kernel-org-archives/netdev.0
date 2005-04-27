From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 6/6] e100: Driver version, white
 space, comments, device id (fwd)
Date: Wed, 27 Apr 2005 10:43:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271043140.16797-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Driver version, white space, comments.
Also enabled ICH-7 support

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e=
100.c.new
--- net-drivers-2.6/drivers/net/e100.c=A0 2005-04-07 03:22:36.805273784 -=
0700
+++ net-drivers-2.6/drivers/net/e100.c.new=A0=A0=A0=A0=A0 2005-04-07 03:2=
2:37.251205992 -0700
@@ -155,9 +155,9 @@
=A0
=A0#define DRV_NAME=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 "e100"
=A0#define DRV_EXT=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 "-NAPI"
-#define DRV_VERSION=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 "3.3.6-k2"DRV_EXT
+#define DRV_VERSION=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 "3.4.8-k2"DRV_EXT
=A0#define DRV_DESCRIPTION=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 "In=
tel(R) PRO/100 Network Driver"
-#define DRV_COPYRIGHT=A0 =A0=A0=A0=A0=A0=A0=A0 "Copyright(c) 1999-2004 I=
ntel Corporation"
+#define DRV_COPYRIGHT=A0 =A0=A0=A0=A0=A0=A0=A0 "Copyright(c) 1999-2005 I=
ntel Corporation"
=A0#define PFX=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 DRV_N=
AME ": "
=A0
=A0#define E100_WATCHDOG_PERIOD=A0=A0 (2 * HZ)
@@ -210,11 +210,17 @@ static struct pci_device_id e100_id_tabl
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1069, 6),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x106A, 6),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x106B, 6),
+=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1091, 7),
+=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1092, 7),
+=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1093, 7),
+=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1094, 7),
+=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1095, 7),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1209, 0),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x1229, 0),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x2449, 2),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x2459, 2),
=A0=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x245D, 2),
+=A0=A0=A0=A0=A0=A0 INTEL_8255X_ETHERNET_DEVICE(0x27DC, 7),
=A0=A0=A0=A0=A0=A0=A0 { 0, }
=A0};
=A0MODULE_DEVICE_TABLE(pci, e100_id_table);
