From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] tipc: replace 0 by NULL for pointers
Date: Thu, 25 Dec 2014 12:05:50 +0100
Message-ID: <1419505550-17336-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix sparse warning:
net/tipc/link.c:1924:40: warning: Using plain integer as NULL pointer

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/tipc/link.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 23bcc11..082c3b5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1921,7 +1921,7 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 {
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
-	struct tipc_node *found_node = 0;
+	struct tipc_node *found_node = NULL;
 	int i;
 
 	*bearer_id = 0;
-- 
1.9.1
