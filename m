From: akpm@osdl.org
Subject: [patch 03/13] X.25: Remove unused header files
Date: Sun, 21 Nov 2004 22:43:50 -0800
Message-ID: <200411220644.iAM6i2900628@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andrew Hendry <ahendry@tusc.com.au>

Remove unused header files from X.25

Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/x25/af_x25.c         |    9 ---------
 25-akpm/net/x25/sysctl_net_x25.c |    1 -
 25-akpm/net/x25/x25_dev.c        |   19 -------------------
 25-akpm/net/x25/x25_facilities.c |   14 --------------
 25-akpm/net/x25/x25_in.c         |   14 --------------
 25-akpm/net/x25/x25_link.c       |   13 -------------
 25-akpm/net/x25/x25_out.c        |   13 -------------
 25-akpm/net/x25/x25_subr.c       |   14 --------------
 25-akpm/net/x25/x25_timer.c      |   14 --------------
 9 files changed, 111 deletions(-)

diff -puN net/x25/af_x25.c~x25-remove-unused-header-files net/x25/af_x25.c
--- 25/net/x25/af_x25.c~x25-remove-unused-header-files	2004-11-21 22:42:30.619027440 -0800
+++ 25-akpm/net/x25/af_x25.c	2004-11-21 22:42:30.634025160 -0800
@@ -34,28 +34,19 @@
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
-#include <linux/sockios.h>
 #include <linux/net.h>
-#include <linux/stat.h>
-#include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/termios.h>	/* For TIOCINQ/OUTQ */
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
 #include <net/x25.h>
diff -puN net/x25/sysctl_net_x25.c~x25-remove-unused-header-files net/x25/sysctl_net_x25.c
--- 25/net/x25/sysctl_net_x25.c~x25-remove-unused-header-files	2004-11-21 22:42:30.620027288 -0800
+++ 25-akpm/net/x25/sysctl_net_x25.c	2004-11-21 22:42:30.634025160 -0800
@@ -5,7 +5,6 @@
  * Added /proc/sys/net/x25 directory entry (empty =) ). [MS]
  */
 
-#include <linux/mm.h>
 #include <linux/sysctl.h>
 #include <linux/skbuff.h>
 #include <linux/socket.h>
diff -puN net/x25/x25_dev.c~x25-remove-unused-header-files net/x25/x25_dev.c
--- 25/net/x25/x25_dev.c~x25-remove-unused-header-files	2004-11-21 22:42:30.622026984 -0800
+++ 25-akpm/net/x25/x25_dev.c	2004-11-21 22:42:30.634025160 -0800
@@ -18,29 +18,10 @@
  */
 
 #include <linux/config.h>
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/timer.h>
-#include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/stat.h>
-#include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <asm/system.h>
-#include <asm/uaccess.h>
-#include <linux/fcntl.h>
-#include <linux/termios.h>	/* For TIOCINQ/OUTQ */
-#include <linux/mm.h>
-#include <linux/interrupt.h>
-#include <linux/notifier.h>
-#include <linux/proc_fs.h>
 #include <linux/if_arp.h>
 #include <net/x25.h>
 
diff -puN net/x25/x25_facilities.c~x25-remove-unused-header-files net/x25/x25_facilities.c
--- 25/net/x25/x25_facilities.c~x25-remove-unused-header-files	2004-11-21 22:42:30.623026832 -0800
+++ 25-akpm/net/x25/x25_facilities.c	2004-11-21 22:42:30.635025008 -0800
@@ -19,24 +19,10 @@
  *					  negotiation.
  */
 
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/timer.h>
 #include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <asm/system.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <net/x25.h>
 
 /*
diff -puN net/x25/x25_in.c~x25-remove-unused-header-files net/x25/x25_in.c
--- 25/net/x25/x25_in.c~x25-remove-unused-header-files	2004-11-21 22:42:30.625026528 -0800
+++ 25-akpm/net/x25/x25_in.c	2004-11-21 22:42:30.635025008 -0800
@@ -24,25 +24,11 @@
  */
 
 #include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/timer.h>
 #include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/ip.h>			/* For ip_rcv */
 #include <net/tcp.h>
-#include <asm/system.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <net/x25.h>
 
 static int x25_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
diff -puN net/x25/x25_link.c~x25-remove-unused-header-files net/x25/x25_link.c
--- 25/net/x25/x25_link.c~x25-remove-unused-header-files	2004-11-21 22:42:30.626026376 -0800
+++ 25-akpm/net/x25/x25_link.c	2004-11-21 22:42:30.636024856 -0800
@@ -21,25 +21,12 @@
  *	2000-09-04	Henner Eisen	  dev_hold() / dev_put() for x25_neigh.
  */
 
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/timer.h>
-#include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <net/sock.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <linux/init.h>
 #include <net/x25.h>
 
diff -puN net/x25/x25_out.c~x25-remove-unused-header-files net/x25/x25_out.c
--- 25/net/x25/x25_out.c~x25-remove-unused-header-files	2004-11-21 22:42:30.627026224 -0800
+++ 25-akpm/net/x25/x25_out.c	2004-11-21 22:42:30.636024856 -0800
@@ -22,24 +22,11 @@
  *					needed cleaned seq-number fields.
  */
 
-#include <linux/errno.h>
-#include <linux/types.h>
 #include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/timer.h>
 #include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <asm/system.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <net/x25.h>
 
 static int x25_pacsize_to_bytes(unsigned int pacsize)
diff -puN net/x25/x25_subr.c~x25-remove-unused-header-files net/x25/x25_subr.c
--- 25/net/x25/x25_subr.c~x25-remove-unused-header-files	2004-11-21 22:42:30.629025920 -0800
+++ 25-akpm/net/x25/x25_subr.c	2004-11-21 22:42:30.637024704 -0800
@@ -21,25 +21,11 @@
  *	jun/24/01	Arnaldo C. Melo	  use skb_queue_purge, cleanups
  */
 
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
 #include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/timer.h>
 #include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp.h>
-#include <asm/system.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <net/x25.h>
 
 /*
diff -puN net/x25/x25_timer.c~x25-remove-unused-header-files net/x25/x25_timer.c
--- 25/net/x25/x25_timer.c~x25-remove-unused-header-files	2004-11-21 22:42:30.630025768 -0800
+++ 25-akpm/net/x25/x25_timer.c	2004-11-21 22:42:30.638024552 -0800
@@ -20,24 +20,10 @@
  */
 
 #include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/timer.h>
-#include <linux/string.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp.h>
-#include <asm/system.h>
-#include <linux/fcntl.h>
-#include <linux/mm.h>
-#include <linux/interrupt.h>
 #include <net/x25.h>
 
 static void x25_heartbeat_expiry(unsigned long);
_
