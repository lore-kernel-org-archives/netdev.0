From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: [PATCH] clean up net/802/Makefile (small version)
Date: Thu, 20 Mar 2003 23:33:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030320223329.GB13641@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch simply removes a couple of lines with duplicated
functionality. Patch is against 2.4.20.

Arnaldo, are you the correct maintainer for this?

J=F6rn

--=20
Victory in war is not repetitious.
-- Sun Tzu

--- linux-2.4.20/net/802/Makefile	Sat Aug  3 02:39:46 2002
+++ linux-2.4.20/net/802/Makefile.1	Thu Mar 20 23:20:05 2003
@@ -15,13 +15,9 @@
=20
 obj-$(CONFIG_SYSCTL) +=3D sysctl_net_802.o
 obj-$(CONFIG_LLC) +=3D llc_sendpdu.o llc_utility.o cl2llc.o llc_macinit.=
o
-ifeq ($(CONFIG_SYSCTL),y)
-obj-y +=3D sysctl_net_802.o
-endif
=20
 ifeq ($(CONFIG_LLC),y)
 subdir-y +=3D transit
-obj-y +=3D llc_sendpdu.o llc_utility.o cl2llc.o llc_macinit.o
 SNAP =3D y
 endif
=20
