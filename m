From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipx: replace long unsigned int by unsigned long
Date: Mon, 27 Oct 2014 19:05:33 +0100
Message-ID: <1414433133-29161-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use standard unsigned long.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipx/ipx_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index e15c16a..c0cb442 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -90,7 +90,7 @@ static int ipx_seq_route_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(rt->ir_net));
 	if (rt->ir_routed)
 		seq_printf(seq, "%08lX     %02X%02X%02X%02X%02X%02X\n",
-			   (long unsigned int)ntohl(rt->ir_intrfc->if_netnum),
+			   (unsigned long)ntohl(rt->ir_intrfc->if_netnum),
 			   rt->ir_router_node[0], rt->ir_router_node[1],
 			   rt->ir_router_node[2], rt->ir_router_node[3],
 			   rt->ir_router_node[4], rt->ir_router_node[5]);
-- 
1.9.1
