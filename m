From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0729/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:38 +0800
Message-ID: <20160802114038.30660-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, mpe@ellerman.id.au,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56451 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934090AbcHBMSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:18:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 7a0281a..6d3f39e 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -55,7 +55,7 @@ static int use_msi = 1;
 static int use_msi_x = 1;
 
 static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
-module_param(auto_fw_reset, int, 0644);
+module_param(auto_fw_reset, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(auto_fw_reset,"Auto firmware reset (0=disabled, 1=enabled");
 
 static int netxen_nic_probe(struct pci_dev *pdev,
-- 
2.9.2
