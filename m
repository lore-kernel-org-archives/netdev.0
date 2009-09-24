From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH 3/3 V2] i2400m-sdio: select IWMC3200TOP in Kconfig
Date: Thu, 24 Sep 2009 11:00:56 +0300
Message-ID: <1253779256-17058-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com, Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i2400m-sdio requires iwmc3200top for its operation

create separate config option to separate 3200 specifics
from eventual further wimax sdio HW.

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
V2: create separate config option as discussed with Inaky

 drivers/net/wimax/i2400m/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
index d623b3d..9723c5c 100644
--- a/drivers/net/wimax/i2400m/Kconfig
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -31,6 +31,15 @@ config WIMAX_I2400M_SDIO
 
 	  If unsure, it is safe to select M (module).
 
+config WIMAX_IWMC3200_SDIO
+	bool "Intel Wireless Multicom WiMAX Connection 3200 over SDIO"
+	depends on WIMAX_I2400M_SDIO
+	select IWMC3200TOP
+	help
+	  Select if you have a device based on the Intel Multicom WiMAX
+          Connection 3200 over SDIO.
+ 
+
 config WIMAX_I2400M_DEBUG_LEVEL
 	int "WiMAX i2400m debug level"
 	depends on WIMAX_I2400M
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

