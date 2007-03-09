From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 4/5] NetXen: Fix the reading of MAC adddress during probe
Date: Fri, 9 Mar 2007 00:11:05 -0800
Message-ID: <200703090811.l298B5GV011824@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:27439 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965780AbXCIILH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 03:11:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix the reading of MAC adddress during probe

Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 121a5f9..7c27f15 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -451,7 +451,7 @@ #endif
 		valid_mac = 0;
 
 	if (valid_mac) {
-		unsigned char *p = (unsigned char *)&mac_addr[i];
+		unsigned char *p = (unsigned char *)&mac_addr[adapter->portnum];
 		netdev->dev_addr[0] = *(p + 5);
 		netdev->dev_addr[1] = *(p + 4);
 		netdev->dev_addr[2] = *(p + 3);
