From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0757/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:21 +0800
Message-ID: <20160802114321.32583-1-baolex.ni@intel.com>
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
 drivers/net/wan/pc300too.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index db36385..0356e99 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -525,9 +525,9 @@ MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("Cyclades PC300 serial port driver");
 MODULE_LICENSE("GPL v2");
 MODULE_DEVICE_TABLE(pci, pc300_pci_tbl);
-module_param(pci_clock_freq, int, 0444);
+module_param(pci_clock_freq, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(pci_clock_freq, "System PCI clock frequency in Hz");
-module_param(use_crystal_clock, int, 0444);
+module_param(use_crystal_clock, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_crystal_clock,
 		 "Use 24.576 MHz clock instead of PCI clock");
 module_init(pc300_init_module);
-- 
2.9.2
