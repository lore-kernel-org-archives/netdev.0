From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) remove duplicate of irlan_state
Date: Mon, 18 Aug 2003 12:24:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818122438.66cb8d81.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove duplicate string definition. Same table already defined and
exported in irlan_event.c

diff -Nru a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
--- a/net/irda/irlan/irlan_common.c	Mon Aug 18 11:09:50 2003
+++ b/net/irda/irlan/irlan_common.c	Mon Aug 18 11:09:50 2003
@@ -74,20 +74,6 @@
 static int access = ACCESS_PEER; /* PEER, DIRECT or HOSTED */
 
 #ifdef CONFIG_PROC_FS
-static char *irlan_state[] = {
-	"IRLAN_IDLE",
-	"IRLAN_QUERY",
-	"IRLAN_CONN", 
-	"IRLAN_INFO",
-	"IRLAN_MEDIA",
-	"IRLAN_OPEN",
-	"IRLAN_WAIT",
-	"IRLAN_ARB", 
-	"IRLAN_DATA",
-	"IRLAN_CLOSE",
-	"IRLAN_SYNC"
-};
-
 static char *irlan_access[] = {
 	"UNKNOWN",
 	"DIRECT",
