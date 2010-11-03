From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] netxen: remove unused firmware exports
Date: Wed, 3 Nov 2010 00:25:31 -0400
Message-ID: <20101103043021.5321.73681.sendpatchset@localhost.localdomain>
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Amerigo Wang <amwang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab0KCEZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 00:25:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quote from Amit Salecha:

"Actually I was not updated, NX_UNIFIED_ROMIMAGE_NAME (phanfw.bin) is already
submitted and its present in linux-firmware.git.

I will get back to you on NX_P2_MN_ROMIMAGE_NAME, NX_P3_CT_ROMIMAGE_NAME and
NX_P3_MN_ROMIMAGE_NAME. Whether this will be submitted ?"

We have to remove these, otherwise we will get wrong info from modinfo.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Cc: Narender Kumar <narender.kumar@qlogic.com>

---
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 50820be..5ddf112 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -41,9 +41,6 @@
 MODULE_DESCRIPTION("QLogic/NetXen (1/10) GbE Converged Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
-MODULE_FIRMWARE(NX_P2_MN_ROMIMAGE_NAME);
-MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
-MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);
 MODULE_FIRMWARE(NX_UNIFIED_ROMIMAGE_NAME);
 
 char netxen_nic_driver_name[] = "netxen_nic";
