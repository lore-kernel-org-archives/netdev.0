From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.5 patch] remove an unneeded #if from net/ipv6/af_inet6.c
Date: Sat, 18 Jan 2003 18:19:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030118171921.GJ10647@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pedro Roque <roque@di.fc.ul.pt>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below removes an unneeded #if from net/ipv6/af_inet6.c:
- kernel 2.0 is too ancient to check for
- the MODULE_* macros have empty definitions #if !MODULE

I've tested the compilation with 2.5.59.

Please apply
Adrian


--- linux-2.5.59-full/net/ipv6/af_inet6.c.old	2003-01-18 18:11:08.000000000 +0100
+++ linux-2.5.59-full/net/ipv6/af_inet6.c	2003-01-18 18:11:38.000000000 +0100
@@ -67,11 +67,9 @@
 			      module for allowing unload */
 #endif
 
-#if defined(MODULE) && LINUX_VERSION_CODE > 0x20115
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
 MODULE_PARM(unloadable, "i");
-#endif
 
 /* IPv6 procfs goodies... */
 
