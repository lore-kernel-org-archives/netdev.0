From: Daniele Bellucci <bellucda@tiscali.it>
Subject: [PATCH] make pktgen depends on procfs [2.6.0-test3]
Date: Mon, 18 Aug 2003 23:26:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308182326.10798.bellucda@tiscali.it>
Reply-To: bellucda@tiscali.it
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

IMHO pktgen should depends on proc fs to avoid the following compilation error:

net/core/pktgen.c: In function `create_proc_dir':
net/core/pktgen.c:1296: `proc_net' undeclared (first use in this function)
net/core/pktgen.c:1296: (Each undeclared identifier is reported only once
net/core/pktgen.c:1296: for each function it appears in.)
make[2]: *** [net/core/pktgen.o] Error 1
make[1]: *** [net/core] Error 2
make: *** [net] Error 2


diff -urN 1.0/net/Kconfig 1.1/net/Kconfig
--- 1.0/net/Kconfig	2003-08-18 23:25:02.000000000 +0200
+++ 1.1/net/Kconfig	2003-08-18 23:25:13.000000000 +0200
@@ -661,6 +661,7 @@
 
 config NET_PKTGEN
 	tristate "Packet Generator (USE WITH CAUTION)"
+	depends on CONFIG_PROC_FS
 	---help---
 	  This module will inject preconfigured packets, at a configurable
 	  rate, out of a given interface.  It is used for network interface


-- 
Daniele.
