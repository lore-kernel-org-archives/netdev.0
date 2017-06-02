From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] rxrpc: remove redundant proc_remove call
Date: Fri,  2 Jun 2017 16:22:27 +0100
Message-ID: <20170602152227.3626-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The proc_remove call is dead code as it occurs after a return and
hence can never be called. Remove it.

Detected by CoverityScan, CID#1437743 ("Logically dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/rxrpc/net_ns.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rxrpc/net_ns.c b/net/rxrpc/net_ns.c
index 26449a6bb076..7edceb8522f5 100644
--- a/net/rxrpc/net_ns.c
+++ b/net/rxrpc/net_ns.c
@@ -59,7 +59,6 @@ static __net_init int rxrpc_init_net(struct net *net)
 	proc_create("conns", 0444, rxnet->proc_net, &rxrpc_connection_seq_fops);
 	return 0;
 
-	proc_remove(rxnet->proc_net);
 err_proc:
 	return ret;
 }
-- 
2.11.0

