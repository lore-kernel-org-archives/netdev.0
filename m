From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 06/15] batman-adv: kernel doc fixes for
	main.{c, h}
Date: Thu,  8 Jan 2015 16:15:11 +0100
Message-ID: <1420730120-9844-7-git-send-email-antonio@meshcoding.com>
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
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
---
 net/batman-adv/main.c | 4 ++--
 net/batman-adv/main.h | 5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d1183e8..2cdd25a 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -651,7 +651,7 @@ static struct batadv_tvlv_handler
 /**
  * batadv_tvlv_container_free_ref - decrement the tvlv container refcoun=
ter and
  *  possibly free it
- * @tvlv_handler: the tvlv container to free
+ * @tvlv: the tvlv container to free
  */
 static void batadv_tvlv_container_free_ref(struct batadv_tvlv_container =
*tvlv)
 {
@@ -800,7 +800,7 @@ void batadv_tvlv_container_register(struct batadv_pri=
v *bat_priv,
  *  requested packet size
  * @packet_buff: packet buffer
  * @packet_buff_len: packet buffer size
- * @packet_min_len: requested packet minimum size
+ * @min_packet_len: requested packet minimum size
  * @additional_packet_len: requested additional packet size on top of mi=
nimum
  *  size
  *
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index a1fcd88..2a59b04 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -92,9 +92,8 @@
 /* numbers of originator to contact for any PUT/GET DHT operation */
 #define BATADV_DAT_CANDIDATES_NUM 3
=20
-/**
- * BATADV_TQ_SIMILARITY_THRESHOLD - TQ points that a secondary metric ca=
n differ
- *  at most from the primary one in order to be still considered accepta=
ble
+/* BATADV_TQ_SIMILARITY_THRESHOLD - TQ points that a secondary metric ca=
n differ
+ * at most from the primary one in order to be still considered acceptab=
le
  */
 #define BATADV_TQ_SIMILARITY_THRESHOLD 50
=20
--=20
2.2.1
