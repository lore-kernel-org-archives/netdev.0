From: Lauri Kasanen <cand-KK0ffGbhmjU@public.gmane.org>
Subject: [PATCH v2] carl9170: Clarify kconfig text
Date: Sat, 16 Apr 2016 17:18:56 +0300
Message-ID: <20160416171856.1769c0e16bcc75372407e06f@gmx.com>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com>
	<1466768.7dLuLFSDol@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466768.7dLuLFSDol@debian64>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The previous text was confusing, leading readers to think this
driver was a duplicate, and so didn't need to be enabled.

After the removal of the older staging driver, this is the only
driver in mainline for these devices.

Signed-off-by: Lauri Kasanen <cand-KK0ffGbhmjU@public.gmane.org>
---
v2: Remove the mention of the previous driver, suggested by Christian.

 drivers/net/wireless/ath/carl9170/Kconfig | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/Kconfig b/drivers/net/wireless/ath/carl9170/Kconfig
index 1a796e5..2e34bae 100644
--- a/drivers/net/wireless/ath/carl9170/Kconfig
+++ b/drivers/net/wireless/ath/carl9170/Kconfig
@@ -5,12 +5,10 @@ config CARL9170
 	select FW_LOADER
 	select CRC32
 	help
-	  This is another driver for the Atheros "otus" 802.11n USB devices.
+	  This is the mainline driver for the Atheros "otus" 802.11n USB devices.
 
-	  This driver provides more features than the original,
-	  but it needs a special firmware (carl9170-1.fw) to do that.
