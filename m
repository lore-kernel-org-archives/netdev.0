From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] gc_min_interval in milleseconds via /proc
Date: Wed, 26 Jan 2005 16:20:42 +0100
Message-ID: <16887.46410.873506.298630@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hello!
The second resolution is very inconvenient. Milleseconds would be nicer.

 cat /proc/sys/net/ipv4/route/gc_min_interval 
500


--- net/ipv4/route.c.orig	2005-01-25 13:58:29.210846472 +0100
+++ net/ipv4/route.c	2005-01-25 14:25:52.116086912 +0100
@@ -2532,9 +2532,9 @@
 		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL,
 		.procname	= "gc_min_interval",
 		.data		= &ip_rt_gc_min_interval,
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
 		.strategy	= &sysctl_jiffies,
 	},


						--ro
