From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 02/17] tipc: Fix build.
Date: Fri, 22 Aug 2014 18:09:05 -0400
Message-ID: <1408745360-23560-3-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: "David S. Miller" <davem@davemloft.net>

Missing semicolon in range check fix.

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/port.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/port.h b/net/tipc/port.h
index a69118f..3087da3 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -182,8 +182,9 @@ static inline int tipc_port_importance(struct tipc_port *port)
 static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
 {
 	if (imp > TIPC_CRITICAL_IMPORTANCE)
-		return -EINVAL
+		return -EINVAL;
 	msg_set_importance(&port->phdr, (u32)imp);
+	return 0;
 }
 
 #endif
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
