From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH 3.6-rc3 v2] wlcore: Declare MODULE_FIRMWARE usage
Date: Wed, 29 Aug 2012 13:09:33 -0600
Message-ID: <1346267373-19591-1-git-send-email-tim.gardner@canonical.com>
References: <1346266668.3935.23.camel@cumari.coelho.fi>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Luciano Coelho <coelho@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346266668.3935.23.camel@cumari.coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare any firmware that might be used by this driver.
If all drivers declare their firmware usage, then a sufficiently
complete list of firmware files can then be used to pare down
the external linux-firmware package to just the files in actual use.

Cc: Luciano Coelho <coelho@ti.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/wireless/ti/wlcore/main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 7254860..a55ace6 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5663,3 +5663,4 @@ MODULE_PARM_DESC(no_recovery, "Prevent HW recovery. FW will remain stuck.");
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Luciano Coelho <coelho@ti.com>");
 MODULE_AUTHOR("Juuso Oikarinen <juuso.oikarinen@nokia.com>");
+MODULE_FIRMWARE(WL12XX_NVS_NAME);
-- 
1.7.9.5
