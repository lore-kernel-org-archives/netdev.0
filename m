From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 net-next] ipx: remove unnecessary casting on ntohl
Date: Mon, 27 Oct 2014 20:55:08 +0100
Message-ID: <1414439709-5870-1-git-send-email-fabf@skynet.be>
Cc: joe@perches.com, Fabian Frederick <fabf@skynet.be>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use %08X instead of %08lX and remove casting.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: remove casting instead of long unsigned int -> unsigned long
(suggested by Joe Perches)

 net/ipx/ipx_proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index e15c16a..8391191 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -89,8 +89,8 @@ static int ipx_seq_route_show(struct seq_file *seq, void *v)
 
 	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(rt->ir_net));
 	if (rt->ir_routed)
-		seq_printf(seq, "%08lX     %02X%02X%02X%02X%02X%02X\n",
-			   (long unsigned int)ntohl(rt->ir_intrfc->if_netnum),
+		seq_printf(seq, "%08X     %02X%02X%02X%02X%02X%02X\n",
+			   ntohl(rt->ir_intrfc->if_netnum),
 			   rt->ir_router_node[0], rt->ir_router_node[1],
 			   rt->ir_router_node[2], rt->ir_router_node[3],
 			   rt->ir_router_node[4], rt->ir_router_node[5]);
-- 
1.9.1
