From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 2/3]drivers:net:rrunner.c Fix typo occationally to occasionally
Date: Tue, 15 Feb 2011 22:55:02 -0800
Message-ID: <1297839302-3125-1-git-send-email-justinmattock@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The below patch fixes a typo occationally to occasionally.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/net/rrunner.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index e68c941..6dceeb5 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1072,7 +1072,7 @@ static irqreturn_t rr_interrupt(int irq, void *dev_id)
 	txcon = rrpriv->dirty_tx;
 	if (txcsmr != txcon) {
 		do {
-			/* Due to occational firmware TX producer/consumer out
+			/* Due to occasional firmware TX producer/consumer out
 			 * of sync. error need to check entry in ring -kbf
 			 */
 			if(rrpriv->tx_skbuff[txcon]){
-- 
1.6.5.2.180.gc5b3e
