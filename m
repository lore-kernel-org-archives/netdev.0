From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] RTNETLINK: Protocol family wildcard dumping for routing rules
Date: Thu, 7 Apr 2005 23:38:38 +0200
Message-ID: <20050407213838.GW26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

I would appreciate if this could go in before 2.6.12, it would
allow the upcomming netconfig pre release to run on 2.6.12 out
of the box.

Please do a

	bk pull bk://kernel.bkbits.net/tgraf/net-2.6-trunk

This will update the following files:

 net/core/rtnetlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

through these ChangeSets:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/07 17:41:18+02:00 tgraf@suug.ch 
#   [RTNETLINK]: Protocol family wildcard dumping for routing rules
#   
#   Be kind to userspace and don't force them to hardcode protocol
#   families just to have it changed again once we support routing
#   rules for more than one protocol family.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/rtnetlink.c
#   2005/04/07 17:41:07+02:00 tgraf@suug.ch +2 -1
#   [RTNETLINK]: Protocol family wildcard dumping for routing rules
# 
diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	2005-04-07 23:13:33 +02:00
+++ b/net/core/rtnetlink.c	2005-04-07 23:13:33 +02:00
@@ -647,7 +647,8 @@
 	[RTM_GETROUTE - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
 	[RTM_NEWNEIGH - RTM_BASE] = { .doit   = neigh_add	      },
 	[RTM_DELNEIGH - RTM_BASE] = { .doit   = neigh_delete	      },
-	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      }
+	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      },
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    }
 };
 
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)
