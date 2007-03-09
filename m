From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/5] NetXen: Update the statistics counter for interrupts
Date: Fri, 9 Mar 2007 00:08:10 -0800
Message-ID: <200703090808.l2988A48011758@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:14554 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752048AbXCIIIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 03:08:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Update the statistics counter for interrupts which have occured.

Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic_main.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index bfeca9a..5fbf6b0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1023,6 +1023,7 @@ netxen_handle_int(struct netxen_adapter 
 	u32 ret = 0;
 
 	DPRINTK(INFO, "Entered handle ISR\n");
+	adapter->stats.ints++;
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		int count = 0;
