From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] neighbour/arp compile fixes
Date: Fri, 29 Oct 2004 02:00:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029000001.GX12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
        "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.27.orig/net/core/neighbour.c	2004-10-29 01:34:19.000000000 +0200
+++ linux-2.4.27/net/core/neighbour.c	2004-10-29 01:53:01.000000000 +0200
@@ -31,6 +31,7 @@
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
+#include <linux/module.h>
 
 #define NEIGH_DEBUG 1
 
--- linux-2.4.27.orig/net/ipv4/arp.c	2004-10-29 01:34:19.000000000 +0200
+++ linux-2.4.27/net/ipv4/arp.c	2004-10-29 01:54:36.000000000 +0200
@@ -94,6 +94,7 @@
 #include <linux/stat.h>
 #include <linux/init.h>
 #include <linux/jhash.h>
+#include <linux/module.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
