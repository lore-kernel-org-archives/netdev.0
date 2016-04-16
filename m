From: Lauri Kasanen <cand@gmx.com>
Subject: [PATCH] carl9170: Clarify kconfig text
Date: Sat, 16 Apr 2016 11:33:12 +0300
Message-ID: <20160416113312.8de2266358165182bb4b4a15@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous text was confusing, leading readers to think this
driver was a duplicate, and so didn't need to be enabled.

After the removal of the older staging driver, this is the only
driver in mainline for these devices.

Signed-off-by: Lauri Kasanen <cand@gmx.com>
---
 drivers/net/wireless/ath/carl9170/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/carl9170/Kconfig b/drivers/net/wireless/ath/carl9170/Kconfig
index 1a796e5..f3e3222 100644
--- a/drivers/net/wireless/ath/carl9170/Kconfig
+++ b/drivers/net/wireless/ath/carl9170/Kconfig
@@ -5,7 +5,7 @@ config CARL9170
 	select FW_LOADER
 	select CRC32
 	help
-	  This is another driver for the Atheros "otus" 802.11n USB devices.
+	  This is the mainline driver for the Atheros "otus" 802.11n USB devices.
 
 	  This driver provides more features than the original,
 	  but it needs a special firmware (carl9170-1.fw) to do that.
-- 
2.6.2
