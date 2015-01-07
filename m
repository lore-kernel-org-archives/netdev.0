From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 6/7] rhashtable: initialize
	atomic nelems variable
Date: Wed, 7 Jan 2015 13:41:57 +0800
Message-ID: <1420609318-3261-7-git-send-email-ying.xue@windriver.com>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 7fb474b..8023b55 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -847,6 +847,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (tbl == NULL)
 		return -ENOMEM;
 
+	atomic_set(&ht->nelems, 0);
 	atomic_set(&ht->shift, ilog2(tbl->size));
 	RCU_INIT_POINTER(ht->tbl, tbl);
 	RCU_INIT_POINTER(ht->future_tbl, tbl);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
