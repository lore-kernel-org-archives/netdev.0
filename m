From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/12] batman-adv: main, batadv_compare_eth return bool
Date: Wed,  3 Jun 2015 16:14:06 +0200
Message-ID: <1433340848-1682-11-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:1112 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192AbbFCOUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:20:43 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Declare the returntype of batadv_compare_eth as bool.
The function called inside this helper function
(ether_addr_equal_unaligned) also uses bool as return value, so there is
no need to return int.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 96876d2..af0a336 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -279,7 +279,7 @@ static inline void _batadv_dbg(int type __always_unused,
  *
  * note: can't use ether_addr_equal() as it requires aligned memory
  */
-static inline int batadv_compare_eth(const void *data1, const void *data2)
+static inline bool batadv_compare_eth(const void *data1, const void *data2)
 {
 	return ether_addr_equal_unaligned(data1, data2);
 }
-- 
2.4.2
