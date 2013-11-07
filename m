From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 2/3] ipv6: increase maximum lifetime of flow labels
Date: Thu,  7 Nov 2013 17:53:13 +0100
Message-ID: <1383843194-22945-2-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:34530 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822Ab3KGQxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 11:53:17 -0500
In-Reply-To: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the last RFC 6437 does not give any constraints
for lifetime of flow labels, the previous RFC 3697
spoke of a minimum of 120 seconds between
reattribution of a flow label.

The maximum linger is currently set to 60 seconds
and does not allow this configuration without
CAP_NET_ADMIN right.

This patch increase the maximum linger to 150
seconds, allowing more flexibility to standard
users.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 4a06ed0..5f10b0d 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -41,7 +41,7 @@
 #define FL_MIN_LINGER	6	/* Minimal linger. It is set to 6sec specified
 				   in old IPv6 RFC. Well, it was reasonable value.
 				 */
-#define FL_MAX_LINGER	60	/* Maximal linger timeout */
+#define FL_MAX_LINGER	150	/* Maximal linger timeout */
 
 /* FL hash table */
 
-- 
1.8.4.rc3
