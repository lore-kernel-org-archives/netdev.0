From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH] wireless/atmel: remove time_t usage
Date: Thu, 23 Feb 2017 17:14:45 +0100
Message-ID: <20170223161445.19200-1-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 linux-wireless@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Simon Kelley <simon@thekelleys.org.uk>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

last_qual never really holds a time. It only holds jiffies. Make it the
same type as jiffies.

Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/wireless/atmel/atmel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/atmel/atmel.c b/drivers/net/wireless/atmel/atmel.c
index e12f62356fd1..27b110dc8cc6 100644
--- a/drivers/net/wireless/atmel/atmel.c
+++ b/drivers/net/wireless/atmel/atmel.c
@@ -513,7 +513,7 @@ struct atmel_private {
 	} station_state;
 
 	int operating_mode, power_mode;
-	time_t last_qual;
+	unsigned long last_qual;
 	int beacons_this_sec;
 	int channel;
 	int reg_domain, config_reg_domain;
-- 
2.11.0
