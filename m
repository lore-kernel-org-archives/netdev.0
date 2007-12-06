From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] remove prototype of ip_rt_advice
Date: Thu, 6 Dec 2007 13:17:43 +0300
Message-ID: <20071206101743.GA10673@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:52067 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751461AbXLFKQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 05:16:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_rt_advice has been gone, so no need to keep prototype and debug message.

Signed-off-by: Denis V. Lunev <den@openvz.org>
--
diff --git a/include/net/route.h b/include/net/route.h
index f7ce625..59b0b19 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -109,7 +109,6 @@ struct in_device;
 extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
-extern void		ip_rt_advice(struct rtable **rp, int advice);
 extern void		rt_cache_flush(int how);
 extern int		__ip_route_output_key(struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct rtable **, struct flowi *flp);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 134cab5..cefae61 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1198,7 +1198,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			unsigned hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
 						rt->fl.oif);
 #if RT_CACHE_DEBUG >= 1
-			printk(KERN_DEBUG "ip_rt_advice: redirect to "
+			printk(KERN_DEBUG "ipv4_negative_advice: redirect to "
 					  "%u.%u.%u.%u/%02x dropped\n",
 				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
 #endif
