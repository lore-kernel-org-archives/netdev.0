From: "Walter Robert Ditzler" <ditwal001-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 16/16] batman-adv: add kernel-doc for
	enum batadv_dbg_level
Date: Sun, 28 Oct 2012 14:32:46 +0100
Message-ID: <!&!AAAAAAAAAAAYAAAAAAAAAOJK0u4CH31Kl5v1RPAzyrZCgQAAEAAAAKjiaB1rjc5LlgmOWy8Wfa0BAAAAAA==@gmail.com>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
 <1351423037-5292-17-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "'The list for a Better Approach To Mobile Ad-hoc Networking'"
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1351423037-5292-17-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Content-Language: de-ch
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

hi batman list,

i recently saw there is a bounce of email in the batman community regarding
patches. is it safe and reliable to use the version from the open-mesh.org
site:

- inux 3.6 => batman-adv 2012.3.x (get batctl 2012.3.x from here)

for production use onto the following configuration:

os: debian 6.0.6
kernel: 3.6.3, batman activated
arch: geode lx and amd64

thanks for a brief answer.

walter

-----Original Message-----
From: B.A.T.M.A.N [mailto:b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org] On Behalf
Of Antonio Quartulli
Sent: Sonntag, 28. Oktober 2012 12:17
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Subject: [B.A.T.M.A.N.] [PATCH 16/16] batman-adv: add kernel-doc for enum
batadv_dbg_level

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/main.h | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h index
9b94f05..897ba6a 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -165,12 +165,19 @@ int batadv_algo_register(struct batadv_algo_ops
*bat_algo_ops);  int batadv_algo_select(struct batadv_priv *bat_priv, char
*name);  int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 
-/* all messages related to routing / flooding / broadcasting / etc */
+/**
+ * enum batadv_dbg_level - available log levels
+ * @BATADV_DBG_BATMAN: OGM and TQ computations related messages
+ * @BATADV_DBG_ROUTES: route added / changed / deleted
+ * @BATADV_DBG_TT: translation table messages
+ * @BATADV_DBG_BLA: bridge loop avoidance messages
+ * @BATADV_DBG_ALL: the union of all the above log levels  */
 enum batadv_dbg_level {
 	BATADV_DBG_BATMAN = BIT(0),
-	BATADV_DBG_ROUTES = BIT(1), /* route added / changed / deleted */
-	BATADV_DBG_TT	  = BIT(2), /* translation table operations */
-	BATADV_DBG_BLA    = BIT(3), /* bridge loop avoidance */
+	BATADV_DBG_ROUTES = BIT(1),
+	BATADV_DBG_TT	  = BIT(2),
+	BATADV_DBG_BLA    = BIT(3),
 	BATADV_DBG_ALL    = 15,
 };
 
--
1.7.12.4
