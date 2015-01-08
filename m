From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/15] batman-adv: checkpatch - No space is necessary after a cast
Date: Thu,  8 Jan 2015 16:15:13 +0100
Message-ID: <1420730120-9844-9-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:11383 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbbAHPQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:16:32 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/main.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2a59b04..18286f8 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -312,10 +312,10 @@ static inline bool batadv_has_timed_out(unsigned long timestamp,
  *  - when adding 128 - it is neither a predecessor nor a successor,
  *  - after adding more than 127 to the starting value - it is a successor
  */
-#define batadv_seq_before(x, y) ({typeof(x) _d1 = (x); \
-				 typeof(y) _d2 = (y); \
-				 typeof(x) _dummy = (_d1 - _d2); \
-				 (void) (&_d1 == &_d2); \
+#define batadv_seq_before(x, y) ({typeof(x)_d1 = (x); \
+				 typeof(y)_d2 = (y); \
+				 typeof(x)_dummy = (_d1 - _d2); \
+				 (void)(&_d1 == &_d2); \
 				 _dummy > batadv_smallest_signed_int(_dummy); })
 #define batadv_seq_after(x, y) batadv_seq_before(y, x)
 
-- 
2.2.1
