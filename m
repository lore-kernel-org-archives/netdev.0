From: Thomas Graf <tgraf@suug.ch>
Subject: [NEIGH] Remove unused fields in struct neigh_parms and neigh_table
Date: Thu, 26 May 2005 20:55:56 +0200
Message-ID: <20050526185556.GA15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526185306.GW15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 45b866033b439e510f3638ce9ac0990446b8b3cd
tree 72baef0bb9b97ac2990bcca05b8f831b30303008
parent 3688d656f38445cc120b0970cd437cad1bb929dd
author Thomas Graf <tgraf@suug.ch> Thu, 26 May 2005 20:42:10 +0200
committer Thomas Graf <tgraf@suug.ch> Thu, 26 May 2005 20:42:10 +0200

 include/net/neighbour.h |    3 ---
 1 files changed, 3 deletions(-)

Index: include/net/neighbour.h
===================================================================
--- 2fbcbf92bed82aaef81b2bcc9baecafd61dfb0ce/include/net/neighbour.h  (mode:100644)
+++ 72baef0bb9b97ac2990bcca05b8f831b30303008/include/net/neighbour.h  (mode:100644)
@@ -69,8 +69,6 @@
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
 	struct neigh_table *tbl;
-	int	entries;
-	void	*priv;
 
 	void	*sysctl_table;
 
@@ -193,7 +191,6 @@
 	atomic_t		entries;
 	rwlock_t		lock;
 	unsigned long		last_rand;
-	struct neigh_parms	*parms_list;
 	kmem_cache_t		*kmem_cachep;
 	struct neigh_statistics	*stats;
 	struct neighbour	**hash_buckets;
