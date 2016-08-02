From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0758/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:26 +0800
Message-ID: <20160802114326.32650-1-baolex.ni@intel.com>
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
 drivers/net/wan/pci200syn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index e845562..cee94c8 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -449,7 +449,7 @@ MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("Goramo PCI200SYN serial port driver");
 MODULE_LICENSE("GPL v2");
 MODULE_DEVICE_TABLE(pci, pci200_pci_tbl);
-module_param(pci_clock_freq, int, 0444);
+module_param(pci_clock_freq, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(pci_clock_freq, "System PCI clock frequency in Hz");
 module_init(pci200_init_module);
 module_exit(pci200_cleanup_module);
-- 
2.9.2
