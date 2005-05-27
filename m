From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/7] [PKT_SCHED] Disable dsmark debugging messages by default
Date: Fri, 27 May 2005 16:52:22 +0200
Message-ID: <20050527145222.GU15391@postel.suug.ch>
References: <20050527145002.GR15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: werner@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050527145002.GR15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 0ecf7991c4f8532a5afc903e175e2bec80585fea
tree 07e28bf36ae4052536820a75bbefc6ac1c7a9098
parent 0297af53b691b2c14b09f65be7b9e32a43a34319
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:35:44 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 14:35:44 +0200

 net/sched/sch_dsmark.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: net/sched/sch_dsmark.c
===================================================================
--- 686339fe0d5a70e263d261324365e65f53cc9880/net/sched/sch_dsmark.c  (mode:100644)
+++ 07e28bf36ae4052536820a75bbefc6ac1c7a9098/net/sched/sch_dsmark.c  (mode:100644)
@@ -18,7 +18,7 @@
 #include <asm/byteorder.h>
 
 
-#if 1 /* control */
+#if 0 /* control */
 #define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
 #else
 #define DPRINTK(format,args...)
