From: Dave Jones <davej@redhat.com>
Subject: Incorrect permissions on route flush sysctl
Date: Mon, 25 Apr 2005 12:01:13 -0400
Message-ID: <20050425160113.GA22919@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This has been brought up before.. http://lkml.org/lkml/2000/1/21/116
but didnt seem to get resolved.  This morning I got someone
file a bugzilla about it breaking sysctl(8).

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.11/net/ipv4/route.c~	2005-04-25 11:57:45.000000000 -0400
+++ linux-2.6.11/net/ipv4/route.c	2005-04-25 11:58:09.000000000 -0400
@@ -2843,7 +2843,7 @@ ctl_table ipv4_route_table[] = {
 		.procname	= "flush",
 		.data		= &flush_delay,
 		.maxlen		= sizeof(int),
-		.mode		= 0644,
+		.mode		= 0200,
 		.proc_handler	= &ipv4_sysctl_rtcache_flush,
 		.strategy	= &ipv4_sysctl_rtcache_flush_strategy,
 	},
