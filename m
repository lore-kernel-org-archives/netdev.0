From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH 3/3] i2400m-sdio: select IWMC3200TOP in Kconfig
Date: Wed, 23 Sep 2009 02:38:44 +0300
Message-ID: <1253662724-16497-4-git-send-email-tomas.winkler@intel.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
 <1253662724-16497-3-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com, Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1253662724-16497-3-git-send-email-tomas.winkler@intel.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i2400m-sdio requires iwmc3200top for its operation

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/net/wimax/i2400m/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
index d623b3d..7368ad5 100644
--- a/drivers/net/wimax/i2400m/Kconfig
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -25,6 +25,7 @@ config WIMAX_I2400M_SDIO
 	tristate "Intel Wireless WiMAX Connection 2400 over SDIO"
 	depends on WIMAX && MMC
 	select WIMAX_I2400M
+	select IWMC3200TOP
 	help
 	  Select if you have a device based on the Intel WiMAX
 	  Connection 2400 over SDIO.
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

