From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: [PATCH][2.6] Move Sungem to gige menu
Date: Mon, 16 Aug 2004 01:05:25 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0408160103440.22078@montezuma.fsmlabs.com>
References: <Pine.LNX.4.58.0408141412550.22077@montezuma.fsmlabs.com>
 <20040815104900.A805@infradead.org> <Pine.LNX.4.58.0408151103490.22078@montezuma.fsmlabs.com>
 <Pine.LNX.4.58.0408151116520.22078@montezuma.fsmlabs.com>
 <20040815162129.A2700@infradead.org> <1092608813.9536.21.camel@gaston>
 <20040815170022.2c3ec056.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040815170022.2c3ec056.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Aug 2004, David S. Miller wrote:

> On Mon, 16 Aug 2004 08:26:53 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> > I suppose the ones used by Sun are all gigabit tho.
>
> Actually no, the ones onboard in the SunBlade100 are
> 10/100 only.

How about;

Index: linux-2.6.8/drivers/net/Kconfig
===================================================================
RCS file: /home/cvsroot/linux-2.6.8/drivers/net/Kconfig,v
retrieving revision 1.1.1.1
diff -u -p -B -r1.1.1.1 Kconfig
--- linux-2.6.8/drivers/net/Kconfig	14 Aug 2004 17:53:39 -0000	1.1.1.1
+++ linux-2.6.8/drivers/net/Kconfig	16 Aug 2004 04:53:44 -0000
@@ -159,11 +159,11 @@ endif
 #	Ethernet
 #

-menu "Ethernet (10 or 100Mbit)"
+menu "Ethernet (10/100/1000Mbit)"
 	depends on NETDEVICES

 config NET_ETHERNET
-	bool "Ethernet (10 or 100Mbit)"
+	bool "Ethernet (10/100/1000Mbit)"
 	---help---
 	  Ethernet (also called IEEE 802.3 or ISO 8802-2) is the most common
 	  type of Local Area Network (LAN) in universities and companies.
@@ -1878,15 +1878,6 @@ config NE_H8300

 source "drivers/net/fec_8xx/Kconfig"

-endmenu
-
-#
-#	Gigabit Ethernet
-#
-
-menu "Ethernet (1000 Mbit)"
-	depends on NETDEVICES
-
 config ACENIC
 	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
 	depends on PCI
