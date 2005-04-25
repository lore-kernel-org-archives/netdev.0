From: Dave Jones <davej@redhat.com>
Subject: Re: Incorrect permissions on route flush sysctl
Date: Mon, 25 Apr 2005 12:16:46 -0400
Message-ID: <20050425161646.GA13778@redhat.com>
References: <20050425160113.GA22919@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050425160113.GA22919@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 25, 2005 at 12:01:13PM -0400, Dave Jones wrote:
 > This has been brought up before.. http://lkml.org/lkml/2000/1/21/116
 > but didnt seem to get resolved.  This morning I got someone
 > file a bugzilla about it breaking sysctl(8).

And here's its ipv6 counterpart.

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.11/net/ipv6/route.c~	2005-04-25 12:16:02.000000000 -0400
+++ linux-2.6.11/net/ipv6/route.c	2005-04-25 12:16:08.000000000 -0400
@@ -2005,7 +2005,7 @@ ctl_table ipv6_route_table[] = {
 		.procname	=	"flush",
          	.data		=	&flush_delay,
 		.maxlen		=	sizeof(int),
-		.mode		=	0644,
+		.mode		=	0200,
          	.proc_handler	=	&ipv6_sysctl_rtcache_flush
 	},
 	{
