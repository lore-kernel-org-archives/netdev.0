From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Fix NULL-ptr dereference in irlmp_get_saddr()
Date: Fri, 28 May 2004 12:56:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B71AF2.2020503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800020208070209080801"
Cc: netdev@oss.sgi.com, jt@bougret.hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010800020208070209080801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes a NULL-ptr dereference in irlmp_get_saddr.

Regards
Patrick

--------------010800020208070209080801
Content-Type: text/x-patch;
 name="irlmp_get_saddr-NULL-ptr.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="irlmp_get_saddr-NULL-ptr.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/28 12:32:37+02:00 kaber@trash.net 
#   [IRDA]: Fix NULL-ptr dereference in irlmp_get_saddr()
# 
# include/net/irda/irlmp.h
#   2004/05/28 12:32:30+02:00 kaber@trash.net +1 -1
#   [IRDA]: Fix NULL-ptr dereference in irlmp_get_saddr()
# 
diff -Nru a/include/net/irda/irlmp.h b/include/net/irda/irlmp.h
--- a/include/net/irda/irlmp.h	2004-05-28 12:35:56 +02:00
+++ b/include/net/irda/irlmp.h	2004-05-28 12:35:56 +02:00
@@ -251,7 +251,7 @@
 
 static inline __u32 irlmp_get_saddr(const struct lsap_cb *self)
 {
-	return (self && !self->lap) ? self->lap->saddr : 0;
+	return (self && self->lap) ? self->lap->saddr : 0;
 }
 
 static inline __u32 irlmp_get_daddr(const struct lsap_cb *self)

--------------010800020208070209080801--
