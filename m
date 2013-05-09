From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 3/8] qlcnic: Fix missing bracket in module parameter.
Date: Thu, 9 May 2013 15:25:11 -0400
Message-ID: <1368127516-9943-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:58437
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752590Ab3EITuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 15:50:01 -0400
In-Reply-To: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 04037b5..d97446a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -37,24 +37,24 @@ MODULE_PARM_DESC(qlcnic_mac_learn,
 		 "Mac Filter (0=learning is disabled, 1=Driver learning is enabled, 2=FDB learning is enabled)");
 
 int qlcnic_use_msi = 1;
-MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
+MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled)");
 module_param_named(use_msi, qlcnic_use_msi, int, 0444);
 
 int qlcnic_use_msi_x = 1;
-MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
+MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled)");
 module_param_named(use_msi_x, qlcnic_use_msi_x, int, 0444);
 
 int qlcnic_auto_fw_reset = 1;
-MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
+MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled)");
 module_param_named(auto_fw_reset, qlcnic_auto_fw_reset, int, 0644);
 
 int qlcnic_load_fw_file;
-MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
+MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file)");
 module_param_named(load_fw_file, qlcnic_load_fw_file, int, 0444);
 
 int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
-MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
+MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled)");
 
 static int qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void qlcnic_remove(struct pci_dev *pdev);
-- 
1.5.6
