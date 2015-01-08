From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 02/15] batman-adv: remove obsolete variable
	primary_iface from orig_node
Date: Thu,  8 Jan 2015 16:15:07 +0100
Message-ID: <1420730120-9844-3-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
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

From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>

This variable became obsolete when changing to the new bonding mechanism
based on the multi interface optimization. Since its not used anywhere,
remove it.

Reported-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
---
 net/batman-adv/types.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8854c05..462a70c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -199,7 +199,6 @@ struct batadv_orig_bat_iv {
 /**
  * struct batadv_orig_node - structure for orig_list maintaining nodes o=
f mesh
  * @orig: originator ethernet address
- * @primary_addr: hosts primary interface address
  * @ifinfo_list: list for routers per outgoing interface
  * @last_bonding_candidate: pointer to last ifinfo of last used router
  * @batadv_dat_addr_t:  address of the orig node in the distributed hash
@@ -244,7 +243,6 @@ struct batadv_orig_bat_iv {
  */
 struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
-	uint8_t primary_addr[ETH_ALEN];
 	struct hlist_head ifinfo_list;
 	struct batadv_orig_ifinfo *last_bonding_candidate;
 #ifdef CONFIG_BATMAN_ADV_DAT
--=20
2.2.1
