From: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH] rfkill-gpio: Add support for the Realtek 8723 BT
Date: Tue, 14 Jul 2015 00:11:34 +0200
Message-ID: <1436825494.20249.47.camel@hadess.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://thread.gmane.org/gmane.linux.kernel.wireless.general/127706/focu
s=127896

Signed-off-by: Bastien Nocera <hadess@hadess.net>

---
 net/rfkill/rfkill-gpio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index d5d58d9..9471024 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -168,6 +168,7 @@ static const struct acpi_device_id
rfkill_acpi_match[] = {
 	{ "BCM2E3D", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM2E40", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM2E64", RFKILL_TYPE_BLUETOOTH },
+	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM4752", RFKILL_TYPE_GPS },
 	{ "LNV4752", RFKILL_TYPE_GPS },
 	{ },
-- 
2.4.3
