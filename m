From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Re: netdev munching messages again?
Date: Thu, 9 Jun 2005 14:27:30 +0100
Message-ID: <20050609132730.GF4927@linux-mips.org>
References: <20050608161314.GM20969@postel.suug.ch> <20050608172809.GF5520@linux-mips.org> <20050608200048.GP20969@postel.suug.ch> <20050608.131044.31642070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: tgraf@suug.ch, hadi@cyberus.ca, netdev@oss.sgi.com,
        Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050608.131044.31642070.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 01:10:44PM -0700, David S. Miller wrote:

Akpm: Patch with netdev address change below.

> I see the delay due to SGI's firewall when I send postings
> out too, and it's very annoying.

Correction on that, while the bloody PIX is still installed, it's SMTP
proxy is disabled.

> The fact that I can send an email faster to Herbert Xu
> in Australia (several thousand miles away) than oss.sgi.com
> (which is a short drive away) would be an amusing anecdote
> if it didn't negatively impact my work.

Performance is partially explained by running sendsnail - against my
resistance.

> I think it's time to move this list to a more reliable and
> efficient place.
>=20
> Ralf, thanks for all of your effort and time maintaining
> oss.sgi.com for our stay as guests via the netdev list.
>=20
> I've created netdev@vger.kernel.org, and folks can start
> to join up there.

How about I simply give you the old subscriber list and turn netdev@oss
into a forward or autoresponder?

>  If someone knows the appropriate
> archive maintainers to contact (marc.theaimsgroup.com
> et al.) please let them know about this transition.  It
> would be much apprecited.

There are archives on oss itself at http://oss.sgi.com/archives/netdev as
well.

  Ralf

 Documentation/networking/vortex.txt |    2 -
 MAINTAINERS                         |   48 ++++++++++++++++++-----------=
-------
 drivers/net/r8169.c                 |    2 -
 net/sched/act_api.c                 |    2 -
 4 files changed, 27 insertions(+), 27 deletions(-)

Index: linux-cvs/drivers/net/r8169.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-cvs.orig/drivers/net/r8169.c	2005-05-20 12:29:58.000000000 +010=
0
+++ linux-cvs/drivers/net/r8169.c	2005-06-09 14:21:10.000000000 +0100
@@ -415,7 +415,7 @@
 	struct work_struct task;
 };
=20
-MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@oss.sgi.com>");
+MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>=
");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param_array(media, int, &num_media, 0);
 module_param(rx_copybreak, int, 0);
Index: linux-cvs/Documentation/networking/vortex.txt
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-cvs.orig/Documentation/networking/vortex.txt	2004-03-11 16:46:4=
0.000000000 +0000
+++ linux-cvs/Documentation/networking/vortex.txt	2005-06-09 14:21:10.000=
000000 +0100
@@ -12,7 +12,7 @@
 Please report problems to one or more of:
=20
   Andrew Morton <andrewm@uow.edu.au>
-  Netdev mailing list <netdev@oss.sgi.com>
+  Netdev mailing list <netdev@vger.kernel.org>
   Linux kernel mailing list <linux-kernel@vger.kernel.org>
=20
 Please note the 'Reporting and Diagnosing Problems' section at the end
Index: linux-cvs/net/sched/act_api.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-cvs.orig/net/sched/act_api.c	2005-05-20 12:30:23.000000000 +010=
0
+++ linux-cvs/net/sched/act_api.c	2005-06-09 14:21:10.000000000 +0100
@@ -881,7 +881,7 @@
 		link_p[RTM_GETACTION-RTM_BASE].dumpit =3D tc_dump_action;
 	}
=20
-	printk("TC classifier action (bugs to netdev@oss.sgi.com cc "
+	printk("TC classifier action (bugs to netdev@vger.kernel.org cc "
 	       "hadi@cyberus.ca)\n");
 	return 0;
 }
Index: linux-cvs/MAINTAINERS
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-cvs.orig/MAINTAINERS	2005-05-20 12:29:29.000000000 +0100
+++ linux-cvs/MAINTAINERS	2005-06-09 14:21:10.000000000 +0100
@@ -73,7 +73,7 @@
 3C359 NETWORK DRIVER
 P:	Mike Phillips
 M:	mikep@linuxtr.net
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 L:	linux-tr@linuxtr.net
 W:	http://www.linuxtr.net
 S:	Maintained
@@ -81,13 +81,13 @@
 3C505 NETWORK DRIVER
 P:	Philip Blundell
 M:	philb@gnu.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 3CR990 NETWORK DRIVER
 P:	David Dillow
 M:	dave@thedillows.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 3W-XXXX ATA-RAID CONTROLLER DRIVER
@@ -130,7 +130,7 @@
 8169 10/100/1000 GIGABIT ETHERNET DRIVER
 P:	Francois Romieu
 M:	romieu@fr.zoreil.com
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 8250/16?50 (AND CLONE UARTS) SERIAL DRIVER
@@ -143,7 +143,7 @@
 8390 NETWORK DRIVERS [WD80x3/SMC-ELITE, SMC-ULTRA, NE2000, 3C503, etc.]
 P:	Paul Gortmaker
 M:	p_gortmaker@yahoo.com
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 A2232 SERIAL BOARD DRIVER
@@ -326,7 +326,7 @@
=20
 ARPD SUPPORT
 P:	Jonathan Layes
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 ASUS ACPI EXTRAS DRIVER
@@ -700,7 +700,7 @@
=20
 DIGI RIGHTSWITCH NETWORK DRIVER
 P:	Rick Richardson
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 W:	http://www.digi.com
 S:	Orphaned
=20
@@ -806,7 +806,7 @@
 ETHEREXPRESS-16 NETWORK DRIVER
 P:	Philip Blundell
 M:	philb@gnu.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 ETHERNET BRIDGE
@@ -869,7 +869,7 @@
 FRAME RELAY DLCI/FRAD (Sangoma drivers too)
 P:	Mike McLagan
 M:	mike.mclagan@linux.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 FREEVXFS FILESYSTEM
@@ -1209,7 +1209,7 @@
 IPX NETWORK LAYER
 P:	Arnaldo Carvalho de Melo
 M:	acme@conectiva.com.br
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 IRDA SUBSYSTEM
@@ -1476,7 +1476,7 @@
 P:	Manish Lachwani
 M:	Manish_Lachwani@pmc-sierra.com
 L:	linux-mips@linux-mips.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Supported
=20
 MATROX FRAMEBUFFER DRIVER
@@ -1586,13 +1586,13 @@
 M:	akpm@osdl.org
 P:	Jeff Garzik
 M:	jgarzik@pobox.com
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 NETWORKING [GENERAL]
 P:	Networking Team
-M:	netdev@oss.sgi.com
-L:	netdev@oss.sgi.com
+M:	netdev@vger.kernel.org
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 NETWORKING [IPv4/IPv6]
@@ -1608,7 +1608,7 @@
 M:	yoshfuji@linux-ipv6.org
 P:	Patrick McHardy
 M:	kaber@coreworks.de
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 IPVS
@@ -1628,7 +1628,7 @@
 P:	Jan-Pascal van Best and Andreas Mohr
 M:	Jan-Pascal van Best <jvbest@qv3pluto.leidenuniv.nl>
 M:	Andreas Mohr <100.30936@germany.net>
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 NINJA SCSI-3 / NINJA SCSI-32Bi (16bit/CardBus) PCMCIA SCSI HOST ADAPTER =
DRIVER
@@ -1670,7 +1670,7 @@
 M:	p2@ace.ulyssis.student.kuleuven.ac.be
 P:	Mike Phillips
 M:	mikep@linuxtr.net=20
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 L:	linux-tr@linuxtr.net
 W:	http://www.linuxtr.net
 S:	Maintained
@@ -1777,7 +1777,7 @@
 PCNET32 NETWORK DRIVER
 P:	Thomas Bogend=F6rfer
 M:	tsbogend@alpha.franken.de
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 PHRAM MTD DRIVER
@@ -1789,7 +1789,7 @@
 POSIX CLOCKS and TIMERS
 P:	George Anzinger
 M:	george@mvista.com
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Supported
=20
 PNP SUPPORT
@@ -1824,7 +1824,7 @@
 PRISM54 WIRELESS DRIVER
 P:	Prism54 Development Team
 M:	prism54-private@prism54.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 W:	http://prism54.org
 S:	Maintained
=20
@@ -2041,7 +2041,7 @@
 P:	Daniele Venzano
 M:	venza@brownhat.org
 W:	http://www.brownhat.org/sis900.html
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 SIS FRAMEBUFFER DRIVER
@@ -2100,7 +2100,7 @@
 SONIC NETWORK DRIVER
 P:	Thomas Bogendoerfer
 M:	tsbogend@alpha.franken.de
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
=20
 SONY VAIO CONTROL DEVICE DRIVER
@@ -2157,7 +2157,7 @@
 SPX NETWORK LAYER
 P:	Jay Schulist
 M:	jschlst@samba.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Supported
=20
 SRM (Alpha) environment access
@@ -2236,7 +2236,7 @@
 TOKEN-RING NETWORK DRIVER
 P:	Mike Phillips
 M:	mikep@linuxtr.net
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 L:	linux-tr@linuxtr.net
 W:	http://www.linuxtr.net
 S:	Maintained
