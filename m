From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [Bugme-new] [Bug 3278] New: Missing include statements
Date: Thu, 26 Aug 2004 13:59:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040826135946.3e7373b3.davem@redhat.com>
References: <20040826134543.344f5c9d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040826134543.344f5c9d.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This was fixed 2 days ago :-)

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/24 11:23:53-07:00 lkml@felipe-alfaro.com 
#   [NETFILTER]: Missing netfilter_ipv4.c include in conntrack proto code.
#   
#   Signed-off-by: Felipe Alfaro Solana <lkml@felipe-alfaro.com>
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/netfilter/ip_conntrack_proto_udp.c
#   2004/08/24 11:23:03-07:00 lkml@felipe-alfaro.com +1 -0
#   [NETFILTER]: Missing netfilter_ipv4.c include in conntrack proto code.
# 
# net/ipv4/netfilter/ip_conntrack_proto_tcp.c
#   2004/08/24 11:23:03-07:00 lkml@felipe-alfaro.com +1 -0
#   [NETFILTER]: Missing netfilter_ipv4.c include in conntrack proto code.
# 
# net/ipv4/netfilter/ip_conntrack_proto_icmp.c
#   2004/08/24 11:23:03-07:00 lkml@felipe-alfaro.com +1 -0
#   [NETFILTER]: Missing netfilter_ipv4.c include in conntrack proto code.
# 
diff -Nru a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c	2004-08-26 13:43:32 -07:00
+++ b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c	2004-08-26 13:43:32 -07:00
@@ -15,6 +15,7 @@
 #include <net/ip.h>
 #include <net/checksum.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv4/ip_conntrack.h>
 #include <linux/netfilter_ipv4/ip_conntrack_core.h>
 #include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
diff -Nru a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	2004-08-26 13:43:32 -07:00
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c	2004-08-26 13:43:32 -07:00
@@ -33,6 +33,7 @@
 #include <net/tcp.h>
 
 #include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv4/ip_conntrack.h>
 #include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
 #include <linux/netfilter_ipv4/lockhelp.h>
diff -Nru a/net/ipv4/netfilter/ip_conntrack_proto_udp.c b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_udp.c	2004-08-26 13:43:32 -07:00
+++ b/net/ipv4/netfilter/ip_conntrack_proto_udp.c	2004-08-26 13:43:32 -07:00
@@ -14,6 +14,7 @@
 #include <linux/udp.h>
 #include <net/checksum.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
 
 unsigned long ip_ct_udp_timeout = 30*HZ;
