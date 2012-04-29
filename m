From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 03/15] batman-adv: add
	biggest_unsigned_int(x) macro
Date: Sun, 29 Apr 2012 10:57:35 +0200
Message-ID: <1335689867-8017-4-git-send-email-ordex@autistici.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1335689867-8017-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

in case of dynamic type variable, it could be needed to compute at compile time
its maximal value. This macro helps in doing that for unsigned integer types

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/main.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index a2b18d0..d9ef4ca 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -221,6 +221,9 @@ static inline bool has_timed_out(unsigned long timestamp, unsigned int timeout)
 /* Returns the smallest signed integer in two's complement with the sizeof x */
 #define smallest_signed_int(x) (1u << (7u + 8u * (sizeof(x) - 1u)))
 
+/* Returns the biggest unsigned integer with the sizeof x */
+#define biggest_unsigned_int(x) (~(x)0)
+
 /* Checks if a sequence number x is a predecessor/successor of y.
  * they handle overflows/underflows and can correctly check for a
  * predecessor/successor unless the variable sequence number has grown by
-- 
1.7.9.4
