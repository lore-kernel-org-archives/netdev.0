From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 5/11] r8169: bump version number
Date: Tue, 24 Aug 2004 00:49:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823224927.GE20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823224813.GD20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Help reviewers realize that the in-kernel driver has evolved lately.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-040 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-040	2004-08-23 23:30:00.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:00.000000000 +0200
@@ -6,6 +6,7 @@
  History:
  Feb  4 2002	- created initially by ShuChen <shuchen@realtek.com.tw>.
  May 20 2002	- Add link status force-mode and TBI mode support.
+        2004	- Massive updates. See kernel SCM system for details.
 =========================================================================
   1. [DEPRECATED: use ethtool instead] The media can be forced in 5 modes.
 	 Command: 'insmod r8169 media = SET_MEDIA'
@@ -32,6 +33,14 @@ VERSION 1.2	<2002/11/30>
 	- Use ether_crc in stock kernel (linux/crc32.h)
 	- Copy mc_filter setup code from 8139cp
 	  (includes an optimization, and avoids set_bit use)
+
+VERSION 1.6LK	<2004/04/14>
+
+	- Merge of Realtek's version 1.6
+	- Conversion to DMA API
+	- Suspend/resume
+	- Endianness
+	- Misc Rx/Tx bugs
 */
 
 #include <linux/module.h>
@@ -47,7 +56,7 @@ VERSION 1.2	<2002/11/30>
 
 #include <asm/io.h>
 
-#define RTL8169_VERSION "1.2"
+#define RTL8169_VERSION "1.6LK"
 #define MODULENAME "r8169"
 #define RTL8169_DRIVER_NAME   MODULENAME " Gigabit Ethernet driver " RTL8169_VERSION
 #define PFX MODULENAME ": "

_
