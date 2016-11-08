From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 03/17] batman-adv: Close two alignment holes
	in batadv_hard_iface
Date: Tue,  8 Nov 2016 17:45:12 +0100
Message-ID: <20161108164526.7518-4-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20161108164526.7518-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

From: Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>

Signed-off-by: Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/types.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 673a22e..c9db184 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -123,8 +123,8 @@ struct batadv_hard_iface_bat_v {
  * @list: list node for batadv_hardif_list
  * @if_num: identificator of the interface
  * @if_status: status of the interface for batman-adv
- * @net_dev: pointer to the net_device
  * @num_bcasts: number of payload re-broadcasts on this interface (ARQ)
+ * @net_dev: pointer to the net_device
  * @hardif_obj: kobject of the per interface sysfs "mesh" directory
  * @refcount: number of contexts the object is used
  * @batman_adv_ptype: packet type describing packets that should be processed by
@@ -141,8 +141,8 @@ struct batadv_hard_iface {
 	struct list_head list;
 	s16 if_num;
 	char if_status;
-	struct net_device *net_dev;
 	u8 num_bcasts;
+	struct net_device *net_dev;
 	struct kobject *hardif_obj;
 	struct kref refcount;
 	struct packet_type batman_adv_ptype;
-- 
2.10.1
