From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH 2/3] Cleanup direct calls into IP stack
Date: Wed, 24 Aug 2005 18:16:35 +0100
Message-ID: <20050824171635.GA8367__15925.6290564828$1124904212$gmane$org@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@linux-mips.org, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All these are claiming to include <net/ip.h> to get ip_rcv() but in
fact don't need the header at all, so away with the inclusion.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/ax25/ax25_ds_in.c  |    1 -
 net/ax25/ax25_std_in.c |    1 -
 net/netrom/nr_in.c     |    1 -
 net/rose/rose_in.c     |    1 -
 4 files changed, 4 deletions(-)

Index: linux-cvs/net/ax25/ax25_ds_in.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_ds_in.c
+++ linux-cvs/net/ax25/ax25_ds_in.c
@@ -22,7 +22,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/ip.h>			/* For ip_rcv */
 #include <net/tcp.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
Index: linux-cvs/net/ax25/ax25_std_in.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_std_in.c
+++ linux-cvs/net/ax25/ax25_std_in.c
@@ -29,7 +29,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/ip.h>			/* For ip_rcv */
 #include <net/tcp.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
Index: linux-cvs/net/netrom/nr_in.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_in.c
+++ linux-cvs/net/netrom/nr_in.c
@@ -23,7 +23,6 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp.h>
-#include <net/ip.h>			/* For ip_rcv */
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <linux/fcntl.h>
Index: linux-cvs/net/rose/rose_in.c
===================================================================
--- linux-cvs.orig/net/rose/rose_in.c
+++ linux-cvs/net/rose/rose_in.c
@@ -26,7 +26,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/ip.h>			/* For ip_rcv */
 #include <net/tcp.h>
 #include <asm/system.h>
 #include <linux/fcntl.h>
