From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 6/7] netxen: add module parameters
Date: Fri,  8 Aug 2008 00:08:44 -0700
Message-ID: <1218179325-32493-7-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:60714 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752226AbYHHHIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 03:08:47 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add user tunable params to enable/disable msi/msix, port auto-neg modes.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 3c424a8..ee56511 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -50,13 +50,21 @@ static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
 
 static int port_mode = NETXEN_PORT_MODE_AUTO_NEG;
+module_param(port_mode, int, 0);
+MODULE_PARM_DESC(port_mode, "Force port mode Auto-Neg XG, 1G or XG");
 
 /* Default to restricted 1G auto-neg mode */
-static int wol_port_mode = 5;
+static int wol_port_mode = NETXEN_PORT_MODE_AUTO_NEG_1G;
+module_param(wol_port_mode, int, 0);
+MODULE_PARM_DESC(wol_port_mode, "Force WOL port mode XG, 1G or Auto-Neg");
 
 static int use_msi = 1;
+module_param(use_msi, bool, 0);
+MODULE_PARM_DESC(use_msi, "Enable or disable MSI interrupts");
 
 static int use_msi_x = 1;
+module_param(use_msi_x, bool, 0);
+MODULE_PARM_DESC(use_msi_x, "Enable or disable MSI-X interrupts");
 
 /* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
-- 
1.5.4.3

