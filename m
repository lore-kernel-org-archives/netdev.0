From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] dst: use const in accessors
Date: Mon, 18 Oct 2004 15:59:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018155909.13e9f3ad@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial, dst cache inline's can use const.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2004-10-15 10:33:43 -07:00
+++ b/include/net/dst.h	2004-10-15 10:33:43 -07:00
@@ -103,19 +103,19 @@
 #ifdef __KERNEL__
 
 static inline u32
-dst_metric(struct dst_entry *dst, int metric)
+dst_metric(const struct dst_entry *dst, int metric)
 {
 	return dst->metrics[metric-1];
 }
 
 static inline u32
-dst_path_metric(struct dst_entry *dst, int metric)
+dst_path_metric(const struct dst_entry *dst, int metric)
 {
 	return dst->path->metrics[metric-1];
 }
 
 static inline u32
-dst_pmtu(struct dst_entry *dst)
+dst_pmtu(const struct dst_entry *dst)
 {
 	u32 mtu = dst_path_metric(dst, RTAX_MTU);
 	/* Yes, _exactly_. This is paranoia. */
