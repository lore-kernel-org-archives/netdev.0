From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Mark IBM TR driver as not 64 bit clean
Date: Fri, 9 Jan 2004 10:09:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109090908.GA1772@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, mikep@linuxtr.net, linux-tr@linuxtr.net
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This driver doesn't seem to be 64bit clean judging from the warnings
on x86-64. Mark it as !64BIT.

-Andi

diff -burpN -X ../KDIFX linux-vanilla/drivers/net/pcmcia/Kconfig linux-2.6.1-amd64/drivers/net/pcmcia/Kconfig
--- linux-vanilla/drivers/net/pcmcia/Kconfig	2003-09-28 10:55:00.000000000 +0200
+++ linux-2.6.1-amd64/drivers/net/pcmcia/Kconfig	2004-01-01 06:56:50.000000000 +0100
@@ -119,7 +119,7 @@ config ARCNET_COM20020_CS
 
 config PCMCIA_IBMTR
 	tristate "IBM PCMCIA tokenring adapter support"
-	depends on NET_PCMCIA && IBMTR!=y && TR && PCMCIA
+	depends on NET_PCMCIA && IBMTR!=y && TR && PCMCIA && !64BIT
 	help
 	  Say Y here if you intend to attach this type of Token Ring PCMCIA
 	  card to your computer. You then also need to say Y to "Token Ring
