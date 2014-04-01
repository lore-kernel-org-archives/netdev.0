From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCHv3 1/5] ARM: tegra: remove obsolete gpio entries
Date: Tue,  1 Apr 2014 17:02:52 +0300
Message-ID: <1396360976-28657-2-git-send-email-heikki.krogerus@linux.intel.com>
References: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Chen-Yu Tsai <wens@csie.org>, Rhyland Klein <rklein@nvidia.com>,
	Marc Dietrich <marvin24@gmx.de>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396360976-28657-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After moving to description based gpio interface in
rfkill-gpio, the gpio numbers are not used any more.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Reviewed-by: Marc Dietrich <marvin24@gmx.de>
Acked-by: Stephen Warren <swarren@nvidia.com>
---
 arch/arm/mach-tegra/board-paz00.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/arm/mach-tegra/board-paz00.c b/arch/arm/mach-tegra/board-paz00.c
index e4dec9f..9c6029b 100644
--- a/arch/arm/mach-tegra/board-paz00.c
+++ b/arch/arm/mach-tegra/board-paz00.c
@@ -23,9 +23,7 @@
 #include "board.h"
 
 static struct rfkill_gpio_platform_data wifi_rfkill_platform_data = {
-	.name		= "wifi_rfkill",
-	.reset_gpio	= 25, /* PD1 */
-	.shutdown_gpio	= 85, /* PK5 */
+	.name	= "wifi_rfkill",
 	.type	= RFKILL_TYPE_WLAN,
 };
 
-- 
1.9.1
