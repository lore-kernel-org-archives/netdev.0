From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] SUNRPC: init per-net rpcbind spinlock
Date: Thu, 16 Feb 2012 17:42:12 +0400
Message-ID: <20120216134212.28924.20601.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/sunrpc_syms.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index d16ac08..21d106e 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -50,6 +50,7 @@ static __net_init int sunrpc_init_net(struct net *net)
 	rpc_pipefs_init_net(net);
 	INIT_LIST_HEAD(&sn->all_clients);
 	spin_lock_init(&sn->rpc_client_lock);
+	spin_lock_init(&sn->rpcb_clnt_lock);
 	return 0;
 
 err_unixgid:
