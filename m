From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] trivial: net/irda/irlmp.c: Fix closing brace followed by if
Date: Fri, 20 Jun 2014 21:48:00 +0200
Message-ID: <1403293680-17568-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 net/irda/irlmp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 98ad6ec..a5f28d4 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -1426,7 +1426,8 @@ __u8 *irlmp_hint_to_service(__u8 *hint)
 		if (hint[1] & HINT_TELEPHONY) {
 			IRDA_DEBUG(1, "Telephony ");
 			service[i++] = S_TELEPHONY;
-		} if (hint[1] & HINT_FILE_SERVER)
+		}
+		if (hint[1] & HINT_FILE_SERVER)
 			IRDA_DEBUG(1, "File Server ");
 
 		if (hint[1] & HINT_COMM) {
-- 
1.9.2
