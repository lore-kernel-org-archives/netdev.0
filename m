From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 2/5] sis900 debugging and revision code
Date: Sun, 12 Dec 2004 13:31:25 +0100
Message-ID: <20041212123125.GC16325@gateway.milesteg.arr>
References: <20041212121852.GA16325@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bi5JUZtvcfApsciF"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041212121852.GA16325@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bi5JUZtvcfApsciF
Content-Type: multipart/mixed; boundary="M38YqGLZlgb6RLPS"
Content-Disposition: inline


--M38YqGLZlgb6RLPS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Version bump

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--M38YqGLZlgb6RLPS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_61.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 60)
+++ b/drivers/net/sis900.c	(revision 61)
@@ -1,6 +1,6 @@
 /* sis900.c: A SiS 900/7016 PCI Fast Ethernet driver for Linux.
    Copyright 1999 Silicon Integrated System Corporation 
-   Revision:	1.08.06 Sep. 24 2002
+   Revision:	1.08.08 Dec. 12 2004
    
    Modified from the driver which is originally written by Donald Becker.
    
@@ -16,8 +16,8 @@
    preliminary Rev. 1.0 Nov. 10, 1998
    SiS 7014 Single Chip 100BASE-TX/10BASE-T Physical Layer Solution,
    preliminary Rev. 1.0 Jan. 18, 1998
-   http://www.sis.com.tw/support/databook.htm
 
+   Rev 1.08.08 Dec. 12 2004 Daniele Venzano use netif_msg for debugging messages
    Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
    Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
    Rev 1.08.05 Jun.  6 2002 Mufasa Yang bug fix for read_eeprom & Tx descriptor over-boundary
@@ -74,7 +74,7 @@
 #include "sis900.h"
 
 #define SIS900_MODULE_NAME "sis900"
-#define SIS900_DRV_VERSION "v1.08.07 11/02/2003"
+#define SIS900_DRV_VERSION "v1.08.08 Dec. 12 2004"
 
 static char version[] __devinitdata =
 KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";

--M38YqGLZlgb6RLPS--

--bi5JUZtvcfApsciF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBvDoc2rmHZCWzV+0RAn21AJ0UObwcBUaP/s74EXdowPtAn+dvTACfcEOA
CC/qu52ZHxaBo8nMKYieoT0=
=CC6M
-----END PGP SIGNATURE-----

--bi5JUZtvcfApsciF--
