From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/13) ddp module comment update
Date: Fri, 29 Aug 2003 14:08:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829140800.5587a03d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

MOD_INC/DEC are gone, so update the comment to match today's reality.

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 13:32:21 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 13:32:21 2003
@@ -1844,13 +1844,10 @@
 module_init(atalk_init);
 
 /*
- * Note on MOD_{INC,DEC}_USE_COUNT:
- *
- * Use counts are incremented/decremented when
- * sockets are created/deleted.
- *
- * AppleTalk interfaces are not incremented until atalkd is run
- * and are only decremented when they are downed.
+ * No explicit module reference count manipulation is needed in the
+ * protocol. Socket layer sets module reference count for us
+ * and interfaces reference counting is done
+ * by the network device layer.
  *
  * Ergo, before the AppleTalk module can be removed, all AppleTalk
  * sockets be closed from user space.
