From: Sean Neakums <sneakums@zork.net>
Subject: [TRIVIAL PATCH] include/net/tcp.h comment fix
Date: Wed, 09 Jun 2004 11:15:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6uy8mxghqd.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I had a few moments' consternation trying to follow from struct
tck_skb_cb  back to cb[], since the struct is named sk_buff.
This may well confuse other unschooled readers in the future.
Against 2.6.7-rc3.


--- S7-rc3/include/net/tcp.h~	2004-05-10 09:22:40.000000000 +0100
+++ S7-rc3/include/net/tcp.h	2004-06-09 11:07:33.000000000 +0100
@@ -1139,7 +1139,7 @@
  * code.  We also store the host-order sequence numbers in
  * here too.  This is 36 bytes on 32-bit architectures,
  * 40 bytes on 64-bit machines, if this grows please adjust
- * skbuff.h:skbuff->cb[xxx] size appropriately.
+ * skbuff.h:sk_buff->cb[xxx] size appropriately.
  */
 struct tcp_skb_cb {
 	union {
