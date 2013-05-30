From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/5] netxen_nic: Log driver version with firmware version
Date: Thu, 30 May 2013 15:51:34 -0400
Message-ID: <1369943498-1732-2-git-send-email-manish.chopra@qlogic.com>
References: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:53324
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757699Ab3E3URE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:17:04 -0400
In-Reply-To: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 51e13d9..2294cd2 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -860,9 +860,9 @@ netxen_check_options(struct netxen_adapter *adapter)
 		adapter->ahw.cut_through = (i & 0x8000) ? 1 : 0;
 	}
 
-	dev_info(&pdev->dev, "firmware v%d.%d.%d [%s]\n",
-			fw_major, fw_minor, fw_build,
-			adapter->ahw.cut_through ? "cut-through" : "legacy");
+	dev_info(&pdev->dev, "Driver v%s, firmware v%d.%d.%d [%s]\n",
+		 NETXEN_NIC_LINUX_VERSIONID, fw_major, fw_minor, fw_build,
+		 adapter->ahw.cut_through ? "cut-through" : "legacy");
 
 	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222))
 		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
-- 
1.7.1
