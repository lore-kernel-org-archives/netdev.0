From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] Rationalise email address: Network Specific Parts
Date: Mon, 13 Oct 2008 10:54:53 +0100
Message-ID: <20081013105453.35eece02@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:45716 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764766AbYJMJzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 05:55:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up the various different email addresses of mine listed in the code
to a single current and valid address. As Dave says his network merges
for 2.6.28 are now done this seems a good point to send them in where
they won't risk disrupting real changes.

Signed-off-by: Alan Cox <alan@redhat.com>

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 5ba4bab..7d15e7c 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -17,7 +17,7 @@
 	Annapolis MD 21403
 
     Fixed (again!) the missing interrupt locking on TX/RX shifting.
-	Alan Cox <Alan.Cox@linux.org>
+	Alan Cox <alan@lxorguk.ukuu.org.uk>
 
     Removed calls to init_etherdev since they are no longer needed, and
     cleaned up modularization just a bit. The driver still allows only
@@ -29,16 +29,16 @@
     the board. Now getting 150K/second FTP with a 3c501 card. Still playing
     with a TX-TX optimisation to see if we can touch 180-200K/second as seems
     theoretically maximum.
-		19950402 Alan Cox <Alan.Cox@linux.org>
+		19950402 Alan Cox <alan@lxorguk.ukuu.org.uk>
 
     Cleaned up for 2.3.x because we broke SMP now.
-		20000208 Alan Cox <alan@redhat.com>
+		20000208 Alan Cox <alan@lxorguk.ukuu.org.uk>
 
     Check up pass for 2.5. Nothing significant changed
-		20021009 Alan Cox <alan@redhat.com>
+		20021009 Alan Cox <alan@lxorguk.ukuu.org.uk>
 
     Fixed zero fill corner case
-		20030104 Alan Cox <alan@redhat.com>
+		20030104 Alan Cox <alan@lxorguk.ukuu.org.uk>
 
 
    For the avoidance of doubt the "preferred form" of this code is one which
@@ -104,7 +104,7 @@
 
 
 static const char version[] =
-	DRV_NAME ".c: " DRV_VERSION " Alan Cox (alan@redhat.com).\n";
+	DRV_NAME ".c: " DRV_VERSION " Alan Cox (alan@lxorguk.ukuu.org.uk).\n";
 
 /*
  *	Braindamage remaining:
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index e4e3241..a0f8b6e 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -18,7 +18,7 @@
 
 	2001/11/17 - Added ethtool support (jgarzik)
 
-	2002/10/28 - Locking updates for 2.5 (alan@redhat.com)
+	2002/10/28 - Locking updates for 2.5 (alan@lxorguk.ukuu.org.uk)
 
 */
 
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index a0b4c85..225b413 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -4,7 +4,7 @@
  *      - Jay Schulist <jschlst@samba.org>
  *
  *	With more than a little help from;
- *	- Alan Cox <Alan.Cox@linux.org> 
+ *	- Alan Cox <alan@lxorguk.ukuu.org.uk> 
  *
  *      Derived from:
  *      - skeleton.c: A network driver outline for linux.
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 795c594..b751c1b 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -8,7 +8,7 @@
  *
  * Many modifications, and currently maintained, by
  *  Philip Blundell <philb@gnu.org>
- * Added the Compaq LTE  Alan Cox <alan@redhat.com>
+ * Added the Compaq LTE  Alan Cox <alan@lxorguk.ukuu.org.uk>
  * Added MCA support Adam Fritzler
  *
  * Note - this driver is experimental still - it has problems on faster
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 95e3464..be0fedf 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -71,7 +71,7 @@ History:
   June 1st, 2000
 	corrected version codes, added support for the latest 2.3 changes
   Oct 28th, 2002
-  	cleaned up for the 2.5 tree <alan@redhat.com>
+  	cleaned up for the 2.5 tree <alan@lxorguk.ukuu.org.uk>
 
  *************************************************************************/
 
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 51ad376..85587a6 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -9,7 +9,7 @@
  *	2 of the License, or (at your option) any later version.
  *
  *	Copyright (C) 1996 Paul Mackerras.
- *	Copyright (C) 1998 Alan Cox <alan@redhat.com>
+ *	Copyright (C) 1998 Alan Cox <alan@lxorguk.ukuu.org.uk>
  *
  *	Modified heavily by Joshua M. Thompson based on Dave Huang's NetBSD driver
  *
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 549a645..29bd853 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -15,7 +15,7 @@
     incorporated herein by reference.
     Donald Becker may be reached at becker@scyld.com
     
-    Updated for 2.5.x by Alan Cox <alan@redhat.com>
+    Updated for 2.5.x by Alan Cox <alan@lxorguk.ukuu.org.uk>
 
 ======================================================================*/
 
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index cfcbea9..ee5dcbf 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -69,7 +69,7 @@ Driver Notes and Issues
 History
 -------------------------------------------------------------------------------
 Log: nmclan_cs.c,v
- * 2.5.75-ac1 2003/07/11 Alan Cox <alan@redhat.com>
+ * 2.5.75-ac1 2003/07/11 Alan Cox <alan@lxorguk.ukuu.org.uk>
  * Fixed hang on card eject as we probe it
  * Cleaned up to use new style locking.
  *
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index ec871f6..c41d687 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -29,7 +29,8 @@
  *
  *	Tigran Aivazian <tigran@sco.com>:	TLan_PciProbe() now uses
  *						new PCI BIOS interface.
- *	Alan Cox	<alan@redhat.com>:	Fixed the out of memory
+ *	Alan Cox	<alan@lxorguk.ukuu.org.uk>:
+ *						Fixed the out of memory
  *						handling.
  *
  *	Torben Mathiasen <torben.mathiasen@compaq.com> New Maintainer!
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index fa73e6e..ed50d28 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -25,7 +25,7 @@
  *  To do:
  *    1. Multicast support.
  *
- *  Initial 2.5 cleanup Alan Cox <alan@redhat.com>  2002/10/28
+ *  Initial 2.5 cleanup Alan Cox <alan@lxorguk.ukuu.org.uk>  2002/10/28
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 6562004..8e46a51 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -23,7 +23,7 @@
     Marcelo Tosatti <marcelo@conectiva.com.br> :
     Made it compile in 2.3 (device to net_device)
 
-    Alan Cox <alan@redhat.com> :
+    Alan Cox <alan@lxorguk.ukuu.org.uk> :
     Cleaned up for kernel merge.
     Removed the back compatibility support
     Reformatted, fixing spelling etc as I went
@@ -49,7 +49,7 @@
     support.  Updated PCI resource allocation.  Do not
     forget to unmap PCI mapped skbs.
 
-    Alan Cox <alan@redhat.com>
+    Alan Cox <alan@lxorguk.ukuu.org.uk>
     Added new PCI identifiers provided by Clear Zhang at ALi
     for their 1563 ethernet device.
 
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index ad20f96..2dced38 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -12,7 +12,7 @@
  *	Scatter gather
  *	More testing
  *
- * The changes are (c) Copyright 2004, Red Hat Inc. <alan@redhat.com>
+ * The changes are (c) Copyright 2004, Red Hat Inc. <alan@lxorguk.ukuu.org.uk>
  * Additional fixes and clean up: Francois Romieu
  *
  * This source has not been verified for use in safety critical systems.
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 243bd8d..ccd9cd3 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -18,7 +18,8 @@
  *	DMA now uses get_free_page as kmalloc buffers may span a 64K 
  *	boundary.
  *
- *	Modified for SMP safety and SMP locking by Alan Cox <alan@redhat.com>
+ *	Modified for SMP safety and SMP locking by Alan Cox
+ *					<alan@lxorguk.ukuu.org.uk>
  *
  *	Performance
  *
diff --git a/drivers/net/wan/z85230.h b/drivers/net/wan/z85230.h
index 4f37239..85b3e78 100644
--- a/drivers/net/wan/z85230.h
+++ b/drivers/net/wan/z85230.h
@@ -2,7 +2,7 @@
  *	Description of Z8530 Z85C30 and Z85230 communications chips
  *
  * Copyright (C) 1995 David S. Miller (davem@caip.rutgers.edu)
- * Copyright (C) 1998 Alan Cox <alan@redhat.com>
+ * Copyright (C) 1998 Alan Cox <alan@lxorguk.ukuu.org.uk>
  */
 
 #ifndef _Z8530_H
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 136220b..e939a73 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -4387,7 +4387,7 @@ MODULE_LICENSE("GPL");
  *
  * Thanks go also to:
  *	James Ashton (jaa101@syseng.anu.edu.au),
- *	Alan Cox (alan@redhat.com),
+ *	Alan Cox (alan@lxorguk.ukuu.org.uk),
  *	Allan Creighton (allanc@cs.usyd.edu.au),
  *	Matthew Geier (matthew@cs.usyd.edu.au),
  *	Remo di Giovanni (remo@cs.usyd.edu.au),
diff --git a/drivers/net/wireless/wavelan.p.h b/drivers/net/wireless/wavelan.p.h
index b33ac47..44d31bb 100644
--- a/drivers/net/wireless/wavelan.p.h
+++ b/drivers/net/wireless/wavelan.p.h
@@ -186,7 +186,7 @@
  *
  * Thanks go also to:
  *	James Ashton <jaa101@syseng.anu.edu.au>,
- *	Alan Cox <alan@redhat.com>,
+ *	Alan Cox <alan@lxorguk.ukuu.org.uk>,
  *	Allan Creighton <allanc@cs.usyd.edu.au>,
  *	Matthew Geier <matthew@cs.usyd.edu.au>,
  *	Remo di Giovanni <remo@cs.usyd.edu.au>,
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index bf1a53b..7f3c735 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -9,7 +9,7 @@
  *
  * Author:	Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Donald Becker, <becker@super.org>
- *		Alan Cox, <alan@redhat.com>
+ *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *		Steve Whitehouse, <gw7rrm@eeshack3.swan.ac.uk>
  *
  *		This program is free software; you can redistribute it and/or
diff --git a/include/linux/if_fddi.h b/include/linux/if_fddi.h
index ae77dae..45de104 100644
--- a/include/linux/if_fddi.h
+++ b/include/linux/if_fddi.h
@@ -12,7 +12,7 @@
  *		if_fddi.h is based on previous if_ether.h and if_tr.h work by
  *			Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *			Donald Becker, <becker@super.org>
- *			Alan Cox, <alan@redhat.com>
+ *			Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *			Steve Whitehouse, <gw7rrm@eeshack3.swan.ac.uk>
  *			Peter De Schrijver, <stud11@cc4.kuleuven.ac.be>
  *
diff --git a/include/linux/if_hippi.h b/include/linux/if_hippi.h
index 94d31ca..f0f2351 100644
--- a/include/linux/if_hippi.h
+++ b/include/linux/if_hippi.h
@@ -9,7 +9,7 @@
  *
  * Author:	Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Donald Becker, <becker@super.org>
- *		Alan Cox, <alan@redhat.com>
+ *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *		Steve Whitehouse, <gw7rrm@eeshack3.swan.ac.uk>
  *		Jes Sorensen, <Jes.Sorensen@cern.ch>
  *
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 7bb3c09..f734a0b 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -2,7 +2,7 @@
  *	Linux NET3:	Internet Group Management Protocol  [IGMP]
  *
  *	Authors:
- *		Alan Cox <Alan.Cox@linux.org>
+ *		Alan Cox <alan@lxorguk.ukuu.org.uk>
  *
  *	Extended to talk the BSD extended IGMP protocol of mrouted 3.6
  *
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d3ea3de..6487585 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -11,7 +11,7 @@
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Corey Minyard <wf-rch!minyard@relay.EU.net>
  *		Donald J. Becker, <becker@cesdis.gsfc.nasa.gov>
- *		Alan Cox, <Alan.Cox@linux.org>
+ *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *		Bjorn Ekwall. <bj0rn@blox.se>
  *              Pekka Riikonen <priikone@poseidon.pspt.fi>
  *
diff --git a/net/802/psnap.c b/net/802/psnap.c
index b3cfe5a..70980ba 100644
--- a/net/802/psnap.c
+++ b/net/802/psnap.c
@@ -1,7 +1,7 @@
 /*
  *	SNAP data link layer. Derived from 802.2
  *
- *		Alan Cox <Alan.Cox@linux.org>,
+ *		Alan Cox <alan@lxorguk.ukuu.org.uk>,
  *		from the 802.2 layer by Greg Page.
  *		Merged in additions from Greg Page's psnap.c.
  *
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0c85042..d3134e7 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -2,7 +2,7 @@
  *	DDP:	An implementation of the AppleTalk DDP protocol for
  *		Ethernet 'ELAP'.
  *
- *		Alan Cox  <Alan.Cox@linux.org>
+ *		Alan Cox  <alan@lxorguk.ukuu.org.uk>
  *
  *		With more than a little assistance from
  *
@@ -1934,6 +1934,6 @@ static void __exit atalk_exit(void)
 module_exit(atalk_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Alan Cox <Alan.Cox@linux.org>");
+MODULE_AUTHOR("Alan Cox <alan@lxorguk.ukuu.org.uk>");
 MODULE_DESCRIPTION("AppleTalk 0.20\n");
 MODULE_ALIAS_NETPROTO(PF_APPLETALK);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 52f577a..ee63184 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -9,7 +9,7 @@
  *	identical recvmsg() code. So we share it here. The poll was
  *	shared before but buried in udp.c so I moved it.
  *
- *	Authors:	Alan Cox <alan@redhat.com>. (datagram_poll() from old
+ *	Authors:	Alan Cox <alan@lxorguk.ukuu.org.uk>. (datagram_poll() from old
  *						     udp.c code)
  *
  *	Fixes:
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 5402b3b..9e2fa39 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -6,7 +6,7 @@
  *		Richard Underwood <richard@wuzz.demon.co.uk>
  *
  *	Stir fried together from the IP multicast and CAP patches above
- *		Alan Cox <Alan.Cox@linux.org>
+ *		Alan Cox <alan@lxorguk.ukuu.org.uk>
  *
  *	Fixes:
  *		Alan Cox	:	Update the device on a real delete
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7f7bb1a..4e22e3a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1,7 +1,7 @@
 /*
  *	Routines having to do with the 'struct sk_buff' memory handlers.
  *
- *	Authors:	Alan Cox <iiitac@pyr.swan.ac.uk>
+ *	Authors:	Alan Cox <alan@lxorguk.ukuu.org.uk>
  *			Florian La Roche <rzsfl@rz.uni-sb.de>
  *
  *	Fixes:
diff --git a/net/core/stream.c b/net/core/stream.c
index a6b3437..8727cea 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -9,7 +9,7 @@
  *
  *     Authors:        Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *                     (from old tcp.c code)
- *                     Alan Cox <alan@redhat.com> (Borrowed comments 8-))
+ *                     Alan Cox <alan@lxorguk.ukuu.org.uk> (Borrowed comments 8-))
  */
 
 #include <linux/module.h>
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 55c355e..72b2de7 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1,7 +1,7 @@
 /*
  *	NET3:	Implementation of the ICMP protocol layer.
  *
- *		Alan Cox, <alan@redhat.com>
+ *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7f9e337..a0d8645 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -9,7 +9,7 @@
  *	seems to fall out with gcc 2.6.2.
  *
  *	Authors:
- *		Alan Cox <Alan.Cox@linux.org>
+ *		Alan Cox <alan@lxorguk.ukuu.org.uk>
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2152d22..e4f81f5 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -6,7 +6,7 @@
  *		The IP fragmentation functionality.
  *
  * Authors:	Fred N. van Kempen <waltje@uWalt.NL.Mugnet.ORG>
- *		Alan Cox <Alan.Cox@linux.org>
+ *		Alan Cox <alan@lxorguk.ukuu.org.uk>
  *
  * Fixes:
  *		Alan Cox	:	Split from ip.c , see ip_input.c for history.
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e0bed56..861978a 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -8,7 +8,7 @@
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Donald Becker, <becker@super.org>
- *		Alan Cox, <Alan.Cox@linux.org>
+ *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *		Richard Underwood
  *		Stefan Becker, <stefanb@yello.ping.de>
  *		Jorge Cwik, <jorge@laser.satlink.net>
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 4c6d2ca..29609d2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -41,7 +41,7 @@
 		Made the tunnels use dev->name not tunnel: when error reporting.
 		Added tx_dropped stat
 
-		-Alan Cox	(Alan.Cox@linux.org) 21 March 95
+		-Alan Cox	(alan@lxorguk.ukuu.org.uk) 21 March 95
 
 	Reworked:
 		Changed to tunnel to destination gateway in addition to the
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c519b8d..b42e082 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1,7 +1,7 @@
 /*
  *	IP multicast routing support for mrouted 3.6/3.8
  *
- *		(c) 1995 Alan Cox, <alan@redhat.com>
+ *		(c) 1995 Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *	  Linux Consultancy and Custom Driver Development
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index eacf4cf..2095abc 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -8,7 +8,7 @@
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Arnt Gulbrandsen, <agulbra@nvg.unit.no>
- *		Alan Cox, <Alan.Cox@linux.org>
+ *		Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *		Hirokazu Takahashi, <taka@valinux.co.jp>
  *
  * Fixes:
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index b0eacc0..2fd8afa 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1,7 +1,7 @@
 /*
  * NETLINK      Kernel-user communication protocol.
  *
- * 		Authors:	Alan Cox <alan@redhat.com>
+ * 		Authors:	Alan Cox <alan@lxorguk.ukuu.org.uk>
  * 				Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
  *
  *		This program is free software; you can redistribute it and/or
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4486c59..9a288d5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3,8 +3,8 @@
  *
  * Client-side transport implementation for sockets.
  *
- * TCP callback races fixes (C) 1998 Red Hat Software <alan@redhat.com>
- * TCP send fixes (C) 1998 Red Hat Software <alan@redhat.com>
+ * TCP callback races fixes (C) 1998 Red Hat
+ * TCP send fixes (C) 1998 Red Hat
  * TCP NFS related read + write fixes
  *  (C) 1999 Dave Airlie, University of Limerick, Ireland <airlied@linux.ie>
  *
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 015606b..c647aab 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1,7 +1,7 @@
 /*
  * NET4:	Implementation of BSD Unix domain sockets.
  *
- * Authors:	Alan Cox, <alan.cox@linux.org>
+ * Authors:	Alan Cox, <alan@lxorguk.ukuu.org.uk>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
