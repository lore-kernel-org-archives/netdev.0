From: akpm@osdl.org
Subject: [patch 08/13] M68k: Update HP300 defconfig (enable DIO and HP Lance Ethernet)
Date: Sun, 21 Nov 2004 22:43:55 -0800
Message-ID: <200411220644.iAM6i6900654@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Geert Uytterhoeven <geert@linux-m68k.org>

M68k: Update HP300 defconfig (enable DIO and HP Lance Ethernet)

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/m68k/configs/hp300_defconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/m68k/configs/hp300_defconfig~m68k-update-hp300-defconfig-enable-dio-and-hp-lance-ethernet arch/m68k/configs/hp300_defconfig
--- 25/arch/m68k/configs/hp300_defconfig~m68k-update-hp300-defconfig-enable-dio-and-hp-lance-ethernet	2004-11-21 22:42:53.343572784 -0800
+++ 25-akpm/arch/m68k/configs/hp300_defconfig	2004-11-21 22:42:53.347572176 -0800
@@ -65,7 +65,7 @@ CONFIG_KMOD=y
 # CONFIG_APOLLO is not set
 # CONFIG_VME is not set
 CONFIG_HP300=y
-# CONFIG_DIO is not set
+CONFIG_DIO=y
 # CONFIG_SUN3X is not set
 # CONFIG_Q40 is not set
 
@@ -404,7 +404,7 @@ CONFIG_EQUALIZER=m
 #
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=m
-# CONFIG_HPLANCE is not set
+CONFIG_HPLANCE=y
 
 #
 # Ethernet (1000 Mbit)
_
