From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0731/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:48 +0800
Message-ID: <20160802114048.30792-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
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
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index fd5d1c9..5632339 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -64,14 +64,14 @@ static const u32 default_msg =
     NETIF_MSG_HW | NETIF_MSG_WOL | 0;
 
 static int debug = -1;	/* defaults above */
-module_param(debug, int, 0664);
+module_param(debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 #define MSIX_IRQ 0
 #define MSI_IRQ 1
 #define LEG_IRQ 2
 static int qlge_irq_type = MSIX_IRQ;
-module_param(qlge_irq_type, int, 0664);
+module_param(qlge_irq_type, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH);
 MODULE_PARM_DESC(qlge_irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
 static int qlge_mpi_coredump;
-- 
2.9.2
