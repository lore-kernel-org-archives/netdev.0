From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 05/16] batman-adv: increase BLA wait periods to 6
Date: Sat,  9 Jan 2016 21:20:10 +0800
Message-ID: <1452345621-15908-6-git-send-email-a@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:34596 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755186AbcAINW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:29 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

If networks take a long time to come up, e.g. due to lossy links, then
the bridge loop avoidance wait time to suppress broadcasts may not wait
long enough and detect a backbone before the mesh is brought up.
Increasing the wait period further to 60 seconds makes this scenario
less likely.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index da9f16c6829b..9dbd9107e7e1 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -109,7 +109,7 @@
 #define BATADV_MAX_AGGREGATION_MS 100
 
 #define BATADV_BLA_PERIOD_LENGTH	10000	/* 10 seconds */
-#define BATADV_BLA_BACKBONE_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 3)
+#define BATADV_BLA_BACKBONE_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 6)
 #define BATADV_BLA_CLAIM_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 10)
 #define BATADV_BLA_WAIT_PERIODS		3
 
-- 
2.7.0
