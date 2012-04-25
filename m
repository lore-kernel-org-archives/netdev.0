From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/15] batman-adv: add biggest_unsigned_int(x) macro
Date: Wed, 25 Apr 2012 15:26:59 +0200
Message-ID: <1335360431-30027-4-git-send-email-ordex@autistici.org>
References: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:38755 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab2DYN0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 09:26:16 -0400
In-Reply-To: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in case of dynamic type variable, it could be needed to compute at compile time
its maximal value. This macro helps in doing that for unsigned integer types

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
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
