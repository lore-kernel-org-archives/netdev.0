From: Chaehyun Lim <chaehyun.lim@gmail.com>
Subject: [PATCH 1/2] ath10k: remove unused <linux/semaphore.h>
Date: Tue, 21 Jun 2016 20:45:38 +0900
Message-ID: <20160621114539.15313-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 Chaehyun Lim <chaehyun.lim@gmail.com>, ath10k@lists.infradead.org
To: kvalo@qca.qualcomm.com
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

<linux/semaphore.h> is not used anymore, so just remove it.

Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>
---
 drivers/net/wireless/ath/ath10k/htc.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/htc.h b/drivers/net/wireless/ath/ath10k/htc.h
index cc82718..0c55cd9 100644
--- a/drivers/net/wireless/ath/ath10k/htc.h
+++ b/drivers/net/wireless/ath/ath10k/htc.h
@@ -22,7 +22,6 @@
 #include <linux/list.h>
 #include <linux/bug.h>
 #include <linux/skbuff.h>
-#include <linux/semaphore.h>
 #include <linux/timer.h>
 
 struct ath10k;
-- 
2.9.0
