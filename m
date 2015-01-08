From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 04/15] batman-adv: kernel doc fixes for
	bridge_loop_avoidance.c
Date: Thu,  8 Jan 2015 16:15:09 +0100
Message-ID: <1420730120-9844-5-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1420730120-9844-1-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
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

From: Martin Hundeb=C3=B8ll <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>

Signed-off-by: Martin Hundeb=C3=B8ll <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>
Acked-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/brid=
ge_loop_avoidance.c
index a957c81..0f0ca43 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -252,7 +252,7 @@ batadv_bla_del_backbone_claims(struct batadv_bla_back=
bone_gw *backbone_gw)
 /**
  * batadv_bla_send_claim - sends a claim frame according to the provided=
 info
  * @bat_priv: the bat priv with all the soft interface information
- * @orig: the mac address to be announced within the claim
+ * @mac: the mac address to be announced within the claim
  * @vid: the VLAN ID
  * @claimtype: the type of the claim (CLAIM, UNCLAIM, ANNOUNCE, ...)
  */
@@ -364,6 +364,7 @@ out:
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address of the originator
  * @vid: the VLAN ID
+ * @own_backbone: set if the requested backbone is local
  *
  * searches for the backbone gw or creates a new one if it could not
  * be found.
@@ -454,6 +455,7 @@ batadv_bla_update_own_backbone_gw(struct batadv_priv =
*bat_priv,
 /**
  * batadv_bla_answer_request - answer a bla request by sending own claim=
s
  * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: interface where the request came on
  * @vid: the vid where the request came on
  *
  * Repeat all of our own claims, and finally send an ANNOUNCE frame
@@ -775,6 +777,7 @@ static int batadv_handle_claim(struct batadv_priv *ba=
t_priv,
 /**
  * batadv_check_claim_group
  * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the primary interface of this batman interface
  * @hw_src: the Hardware source in the ARP Header
  * @hw_dst: the Hardware destination in the ARP Header
  * @ethhdr: pointer to the Ethernet header of the claim frame
@@ -850,6 +853,7 @@ static int batadv_check_claim_group(struct batadv_pri=
v *bat_priv,
 /**
  * batadv_bla_process_claim
  * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the primary hard interface of this batman soft interface
  * @skb: the frame to be checked
  *
  * Check if this is a claim frame, and process it accordingly.
--=20
2.2.1
