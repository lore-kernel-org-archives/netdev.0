From: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next V2 3/3] i2400m-sdio: select IWMC3200TOP in Kconfig
Date: Sat, 17 Oct 2009 21:09:36 +0200
Message-ID: <1255806576-26869-3-git-send-email-tomas.winkler@intel.com>
References: <1255806576-26869-1-git-send-email-tomas.winkler@intel.com>
 <1255806576-26869-2-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1255806576-26869-2-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

i2400m-sdio requires iwmc3200top for its operation

Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Acked-by: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 drivers/net/wimax/i2400m/Kconfig |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2400m/Kconfig
index d623b3d..32cb214 100644
--- a/drivers/net/wimax/i2400m/Kconfig
+++ b/drivers/net/wimax/i2400m/Kconfig
@@ -31,6 +31,14 @@ config WIMAX_I2400M_SDIO
 
 	  If unsure, it is safe to select M (module).
 
+config WIMAX_IWMC3200_SDIO
+	bool "Intel Wireless Multicom WiMAX Connection 3200 over SDIO"
+	depends on WIMAX_I2400M_SDIO
+	select IWMC3200TOP
+	help
+	  Select if you have a device based on the Intel Multicom WiMAX
+          Connection 3200 over SDIO.
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
