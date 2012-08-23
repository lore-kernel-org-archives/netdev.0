From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 03/18] batman-adv: correct comments in bridge
	loop avoidance
Date: Thu, 23 Aug 2012 15:10:12 +0200
Message-ID: <1345727427-20805-4-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1345727427-20805-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 7e60466..5f1ad80 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -281,7 +281,7 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 			 NULL,
 			 /* Ethernet SRC/HW SRC:  originator mac */
 			 primary_if->net_dev->dev_addr,
-			 /* HW DST: FF:43:05:XX:00:00
+			 /* HW DST: FF:43:05:XX:YY:YY
 			  * with XX   = claim type
 			  * and YY:YY = group id
 			  */
@@ -323,7 +323,8 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		break;
 	case BATADV_CLAIM_TYPE_REQUEST:
 		/* request frame
-		 * set HW SRC to the special mac containg the crc
+		 * set HW SRC and header destination to the receiving backbone
+		 * gws mac
 		 */
 		memcpy(hw_src, mac, ETH_ALEN);
 		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
-- 
1.7.9.4
