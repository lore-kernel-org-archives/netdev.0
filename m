From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/4] netxen_nic: Log driver version with firmware version
Date: Fri,  5 Apr 2013 08:36:41 -0400
Message-ID: <1365165403-18348-3-git-send-email-manish.chopra@qlogic.com>
References: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5679 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1161627Ab3DEM76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 08:59:58 -0400
In-Reply-To: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 6049637..cde5109 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -862,9 +862,9 @@ netxen_check_options(struct netxen_adapter *adapter)
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
1.5.6
