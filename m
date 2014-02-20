From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 4/4] net: rfkill: gpio: add ACPI IDs for a Broadcom bluetooth chip
Date: Thu, 20 Feb 2014 14:51:37 +0200
Message-ID: <1392900697-27577-5-git-send-email-heikki.krogerus@linux.intel.com>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Chen-Yu Tsai <wens@csie.org>, Rhyland Klein <rklein@nvidia.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds ACPI IDs for Broadcom bluetooth chip BCM43241 used
on various Baytrail based boards such as Lenovo Miix 2 and
Asus Transformer Book T100TA.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 net/rfkill/rfkill-gpio.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index ec38884..3a38861 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -157,6 +157,9 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 }
 
 static const struct acpi_device_id rfkill_acpi_match[] = {
+	{ "BCM2E1A", RFKILL_TYPE_BLUETOOTH },
+	{ "BCM2E39", RFKILL_TYPE_BLUETOOTH },
+	{ "BCM2E3D", RFKILL_TYPE_BLUETOOTH },
 	{ "BCM4752", RFKILL_TYPE_GPS },
 	{ "LNV4752", RFKILL_TYPE_GPS },
 	{ },
-- 
1.9.0.rc3
