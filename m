From: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] batman-adv:Remove unnessary break statements
	for switch statement in the function batadv_bla_proccess_claim
Date: Thu, 11 Jun 2015 11:10:34 -0400
Message-ID: <1434035434-31224-1-git-send-email-xerofoify@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

This removes the unnessary break statements for the switch
statement in the function, batadv_blav_procces_claim for
checking the structure pointer, bla_dst's variable member,
type due to returning directly for the cases in this switch
if they evaluate to be equal to the value of the member
variable type of the structure pointer, bla_dst and thus
no need to avoid fallthrough with break statements in
this particular switch statement.

Signed-off-by: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index ac4b96e..c9a548a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -961,23 +961,18 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 		if (batadv_handle_claim(bat_priv, primary_if, hw_src,
 					ethhdr->h_source, vid))
 			return 1;
-		break;
 	case BATADV_CLAIM_TYPE_UNCLAIM:
 		if (batadv_handle_unclaim(bat_priv, primary_if,
 					  ethhdr->h_source, hw_src, vid))
 			return 1;
-		break;
-
 	case BATADV_CLAIM_TYPE_ANNOUNCE:
 		if (batadv_handle_announce(bat_priv, hw_src, ethhdr->h_source,
 					   vid))
 			return 1;
-		break;
 	case BATADV_CLAIM_TYPE_REQUEST:
 		if (batadv_handle_request(bat_priv, primary_if, hw_src, ethhdr,
 					  vid))
 			return 1;
-		break;
 	}
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv,
-- 
2.1.4
