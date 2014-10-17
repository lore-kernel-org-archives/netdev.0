From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] netrom: use linux/uaccess.h
Date: Fri, 17 Oct 2014 22:00:22 +0200
Message-ID: <1413576023-26717-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

replace asm/uaccess.h by linux/uaccess.h

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/netrom/af_netrom.c | 2 +-
 net/netrom/nr_dev.c    | 2 +-
 net/netrom/nr_in.c     | 2 +-
 net/netrom/nr_out.c    | 2 +-
 net/netrom/nr_route.c  | 2 +-
 net/netrom/nr_subr.c   | 2 +-
 net/netrom/nr_timer.c  | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 71cf1bf..1b06a1f 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -30,7 +30,7 @@
 #include <linux/skbuff.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/termios.h>	/* For TIOCINQ/OUTQ */
 #include <linux/mm.h>
diff --git a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
index 743262b..6ae063c 100644
--- a/net/netrom/nr_dev.c
+++ b/net/netrom/nr_dev.c
@@ -20,8 +20,8 @@
 #include <linux/in.h>
 #include <linux/if_ether.h>	/* For the statistics structure. */
 #include <linux/slab.h>
+#include <linux/uaccess.h>
 
-#include <asm/uaccess.h>
 #include <asm/io.h>
 
 #include <linux/inet.h>
diff --git a/net/netrom/nr_in.c b/net/netrom/nr_in.c
index c3073a2..80dbd0b 100644
--- a/net/netrom/nr_in.c
+++ b/net/netrom/nr_in.c
@@ -23,7 +23,7 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
diff --git a/net/netrom/nr_out.c b/net/netrom/nr_out.c
index 0b4bcb2..00fbf14 100644
--- a/net/netrom/nr_out.c
+++ b/net/netrom/nr_out.c
@@ -22,7 +22,7 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index b976d5e..96b64d2 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -25,7 +25,7 @@
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/termios.h>	/* For TIOCINQ/OUTQ */
 #include <linux/mm.h>
diff --git a/net/netrom/nr_subr.c b/net/netrom/nr_subr.c
index ca40e22..029c8bb 100644
--- a/net/netrom/nr_subr.c
+++ b/net/netrom/nr_subr.c
@@ -22,7 +22,7 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
diff --git a/net/netrom/nr_timer.c b/net/netrom/nr_timer.c
index ff2c1b1..94d0580 100644
--- a/net/netrom/nr_timer.c
+++ b/net/netrom/nr_timer.c
@@ -23,7 +23,7 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/fcntl.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
-- 
1.9.3

