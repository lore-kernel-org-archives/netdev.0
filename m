From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/11) netrom - fix sysctl initializers
Date: Wed, 13 Aug 2003 15:39:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813153914.608101f7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Jeroen Vreeken <pe1rxq@amsat.org>

Change initializers for syctl values.


diff -Nru a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
--- a/net/netrom/sysctl_net_netrom.c	Wed Aug 13 11:58:15 2003
+++ b/net/netrom/sysctl_net_netrom.c	Wed Aug 13 11:58:15 2003
@@ -15,9 +15,9 @@
 /*
  *	Values taken from NET/ROM documentation.
  */
-static int min_quality[1],       max_quality[] = {255};
-static int min_obs[1],           max_obs[]     = {255};
-static int min_ttl[1],           max_ttl[]     = {255};
+static int min_quality[] = {0}, max_quality[] = {255};
+static int min_obs[]     = {0}, max_obs[]     = {255};
+static int min_ttl[]     = {0}, max_ttl[]     = {255};
 static int min_t1[]      = {5 * HZ};
 static int max_t1[]      = {600 * HZ};
 static int min_n2[]      = {2}, max_n2[]      = {127};
@@ -28,7 +28,7 @@
 static int min_window[]  = {1}, max_window[]  = {127};
 static int min_idle[]    = {0 * HZ};
 static int max_idle[]    = {65535 * HZ};
-static int min_route[1],        max_route[]   = {1};
+static int min_route[]   = {0}, max_route[]   = {1};
 static int min_fails[]   = {1}, max_fails[]   = {10};
 
 static struct ctl_table_header *nr_table_header;
