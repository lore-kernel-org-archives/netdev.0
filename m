From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0756/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:16 +0800
Message-ID: <20160802114316.32517-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, tgraf@suug.ch,
	hannes@stressinduktion.org, daniel@iogearbox.net, pabeni@redhat.com
To: khc@pm.waw.pl, f.fainelli@gmail.com, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
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
 drivers/net/wan/n2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 315bf09..70c31aa 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -562,5 +562,5 @@ module_exit(n2_cleanup);
 MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("RISCom/N2 serial port driver");
 MODULE_LICENSE("GPL v2");
-module_param(hw, charp, 0444);
+module_param(hw, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hw, "io,irq,ram,ports:io,irq,...");
-- 
2.9.2
