From: akpm@osdl.org
Subject: [patch 06/13] M68k HP Lance Ethernet depends on DIO bus support
Date: Sun, 21 Nov 2004 22:43:53 -0800
Message-ID: <200411220644.iAM6i5900643@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Geert Uytterhoeven <geert@linux-m68k.org>

HP Lance Ethernet depends on DIO bus support

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/Kconfig~m68k-hp-lance-ethernet-depends-on-dio-bus-support drivers/net/Kconfig
--- 25/drivers/net/Kconfig~m68k-hp-lance-ethernet-depends-on-dio-bus-support	2004-11-21 22:42:53.065615040 -0800
+++ 25-akpm/drivers/net/Kconfig	2004-11-21 22:42:53.071614128 -0800
@@ -429,7 +429,7 @@ config SUN3_82586
 
 config HPLANCE
 	bool "HP on-board LANCE support"
-	depends on NET_ETHERNET && HP300
+	depends on NET_ETHERNET && DIO
 	select CRC32
 	help
 	  If you want to use the builtin "LANCE" Ethernet controller on an
_
