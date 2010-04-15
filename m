From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net/l2tp/l2tp_debugfs.c: Convert NIPQUAD to %pI4
Date: Thu, 15 Apr 2010 09:41:43 -0700
Message-ID: <1271349703.1726.62.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/l2tp/l2tp_debugfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 908f10f..104ec3b 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -122,8 +122,8 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 	seq_printf(m, "\nTUNNEL %u peer %u", tunnel->tunnel_id, tunnel->peer_tunnel_id);
 	if (tunnel->sock) {
 		struct inet_sock *inet = inet_sk(tunnel->sock);
-		seq_printf(m, " from " NIPQUAD_FMT " to " NIPQUAD_FMT "\n",
-			   NIPQUAD(inet->inet_saddr), NIPQUAD(inet->inet_daddr));
+		seq_printf(m, " from %pI4 to %pI4\n",
+			   &inet->inet_saddr, &inet->inet_daddr);
 		if (tunnel->encap == L2TP_ENCAPTYPE_UDP)
 			seq_printf(m, " source port %hu, dest port %hu\n",
 				   ntohs(inet->inet_sport), ntohs(inet->inet_dport));
