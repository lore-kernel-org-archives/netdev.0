From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 3/4] ipv6: increase maximum lifetime of flow labels
Date: Tue,  5 Nov 2013 15:28:57 +0100
Message-ID: <1383661738-6083-3-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:40712 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157Ab3KEO3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 09:29:12 -0500
In-Reply-To: <1383661738-6083-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the last RFC 6437 does not give any constraints
for lifetime of flow labels, the previous RFC 3697
spoke of a minimum of 120 seconds quarantine
for a flow label.

The maximum linger is currently set to 60 seconds
and does not allow this configuration without
CAP_NET_ADMIN right.

This patch increases the maximum linger to 150
seconds, allowing more flexibility to standard
users.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 76e62a1..41ced9c 100644
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
