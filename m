From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Add appletalk 32bit ioctl emulation
Date: Wed, 20 Oct 2004 00:48:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020004810.35957a87.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, helmut@helios.de
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Helmut Tschemernjak <helmut@helios.de>

Add 32bit ioctl conversion for appletalk ioctls

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/fs/compat_ioctl.c
===================================================================
--- linux.orig/fs/compat_ioctl.c	2004-10-19 01:55:27.%N +0200
+++ linux/fs/compat_ioctl.c	2004-10-19 17:43:50.%N +0200
@@ -69,6 +69,7 @@
 #include <linux/i2c.h>
 #include <linux/i2c-dev.h>
 #include <linux/wireless.h>
+#include <linux/atalk.h>
 
 #include <net/sock.h>          /* siocdevprivate_ioctl */
 #include <net/bluetooth/bluetooth.h>
@@ -3184,6 +3185,13 @@
 HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
+
+/* ioctls used by appletalk ddp.c */
+HANDLE_IOCTL(SIOCATALKDIFADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCDIFADDR, dev_ifsioc)
+HANDLE_IOCTL(SIOCSARP, dev_ifsioc)
+HANDLE_IOCTL(SIOCDARP, dev_ifsioc)
+
 HANDLE_IOCTL(SIOCGIFBRDADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFBRDADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFDSTADDR, dev_ifsioc)
