From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 3/3] net/tipc/name_table.c: Remove unecessary semicolon
Date: Tue, 18 Sep 2012 19:10:45 +0200
Message-ID: <1347988245-31413-3-git-send-email-peter.senna@gmail.com>
References: <1347988245-31413-1-git-send-email-peter.senna@gmail.com>
Cc: allan.stephens@windriver.com, davem@davemloft.net,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	trivial@kernel.org, Peter Senna Tschudin <peter.senna@gmail.com>
To: jon.maloy@ericsson.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347988245-31413-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found by http://coccinelle.lip6.fr/

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
 net/tipc/name_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 98975e8..4675477 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -783,7 +783,7 @@ static int subseq_list(struct sub_seq *sseq, char *buf, int len, u32 depth,
 		if (!list_is_last(&publ->zone_list, &info->zone_list))
 			ret += tipc_snprintf(buf + ret, len - ret,
 					     "\n%33s", " ");
-	};
+	}
 
 	ret += tipc_snprintf(buf + ret, len - ret, "\n");
 	return ret;
-- 
1.7.11.4
