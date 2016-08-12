From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 18/19] batman-adv: Use bitwise instead of arithmetic operator for flags
Date: Fri, 12 Aug 2016 10:56:54 +0200
Message-ID: <1470992215-11009-19-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:35035 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbcHLI5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:37 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

This silences the following coccinelle warning:

"WARNING: sum of probable bitmasks, consider |"

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/multicast.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index cc91507..894df60 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -528,7 +528,7 @@ update:
 	}
 
 	return !(mcast_data.flags &
-		 (BATADV_MCAST_WANT_ALL_IPV4 + BATADV_MCAST_WANT_ALL_IPV6));
+		 (BATADV_MCAST_WANT_ALL_IPV4 | BATADV_MCAST_WANT_ALL_IPV6));
 }
 
 /**
-- 
2.8.1
