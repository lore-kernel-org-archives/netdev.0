From: Joe Perches <joe@perches.com>
Subject: [PATCH 20/24] tipc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:39 -0700
Message-ID: <22c8098d9704a07ce8ccb5b13c6ac531dbb9dd1e.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/tipc/link.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index f89570c..5c96289 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -325,10 +325,8 @@ struct link *tipc_link_create(struct tipc_node *n_ptr,
 	}
 
 	l_ptr = kzalloc(sizeof(*l_ptr), GFP_ATOMIC);
-	if (!l_ptr) {
-		warn("Link creation failed, no memory\n");
+	if (!l_ptr)
 		return NULL;
-	}
 
 	l_ptr->addr = peer;
 	if_name = strchr(b_ptr->name, ':') + 1;
-- 
1.7.6.405.gc1be0
