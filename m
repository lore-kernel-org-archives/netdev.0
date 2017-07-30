From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] netfilter: ipvs: Fix space before '[' error.
Date: Sun, 30 Jul 2017 12:29:25 +0530
Message-ID: <3b2fae111371a2abd12d6838e825452a3c9bd4fa.1501397734.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
        pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.ne
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch.pl error:
ERROR: space prohibited before open square bracket '['.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 12dc8d5..4fc17fc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -439,7 +439,7 @@ static bool tcp_state_active(int state)
 	return tcp_state_active_table[state];
 }
 
-static struct tcp_states_t tcp_states [] = {
+static struct tcp_states_t tcp_states[] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
@@ -462,7 +462,7 @@ static struct tcp_states_t tcp_states [] = {
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
-static struct tcp_states_t tcp_states_dos [] = {
+static struct tcp_states_t tcp_states_dos[] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSA }},
-- 
2.7.4
