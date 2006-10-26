From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sealevel: uses arp_broken_ops
Date: Thu, 26 Oct 2006 14:08:08 -0700
Message-ID: <20061026140809.9b0c8a01.randy.dunlap@oracle.com>
References: <200610251803.15280.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32064 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1423545AbWJZVGr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 17:06:47 -0400
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	alan@lxorguk.ukuu.org.uk
In-Reply-To: <200610251803.15280.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Oct 2006 18:03:13 +0200 Toralf F=F6rster wrote:

> WARNING: "arp_broken_ops" [drivers/net/wan/sealevel.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
>=20
> Here's the config:
=2E..
> # CONFIG_INET is not set
> CONFIG_SEALEVEL_4021=3Dm

---
=46rom: Randy Dunlap <randy.dunlap@oracle.com>

Sealevel uses arp_broken_ops so it needs to depend on INET.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/wan/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2619-rc3-pv.orig/drivers/net/wan/Kconfig
+++ linux-2619-rc3-pv/drivers/net/wan/Kconfig
@@ -127,7 +127,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on WAN && ISA && m && ISA_DMA_API
+	depends on WAN && ISA && m && ISA_DMA_API && INET
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter=
=2E
=20
