From: akpm@osdl.org
Subject: [patch 09/13] M68k: Update Atari defconfig (enable Ethernet and MII)
Date: Sun, 21 Nov 2004 22:43:55 -0800
Message-ID: <200411220644.iAM6i7900667@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Geert Uytterhoeven <geert@linux-m68k.org>

M68k: Update Atari defconfig (enable Ethernet and MII)

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/m68k/configs/atari_defconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -puN arch/m68k/configs/atari_defconfig~m68k-update-atari-defconfig-enable-ethernet-and-mii arch/m68k/configs/atari_defconfig
--- 25/arch/m68k/configs/atari_defconfig~m68k-update-atari-defconfig-enable-ethernet-and-mii	2004-11-21 22:42:53.480551960 -0800
+++ 25-akpm/arch/m68k/configs/atari_defconfig	2004-11-21 22:42:53.484551352 -0800
@@ -430,7 +430,8 @@ CONFIG_EQUALIZER=m
 #
 # Ethernet (10 or 100Mbit)
 #
-# CONFIG_NET_ETHERNET is not set
+CONFIG_NET_ETHERNET=y
+CONFIG_MII=m
 CONFIG_ATARILANCE=m
 
 #
_
