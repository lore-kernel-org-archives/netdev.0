From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0752/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:52 +0800
Message-ID: <20160802114252.32250-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, pabeni@redhat.com, jasowang@redhat.com,
	makita.toshiaki@lab.ntt.co.jp, hannes@stressinduktion.org,
	daniel@iogearbox.net
To: steve.glendinning@shawell.net, f.fainelli@gmail.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/usb/smsc95xx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index dc989a8..8cf6e39 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -77,7 +77,7 @@ struct smsc95xx_priv {
 };
 
 static bool turbo_mode = true;
-module_param(turbo_mode, bool, 0644);
+module_param(turbo_mode, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 
 static int __must_check __smsc95xx_read_reg(struct usbnet *dev, u32 index,
-- 
2.9.2
