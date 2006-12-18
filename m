From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 8/8] NetXen: Reducing ring sizes for IOMMU issue.
Date: Mon, 18 Dec 2006 05:54:36 -0800
Message-ID: <200612181354.kBIDsaR8012247@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:5554 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754061AbWLROWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com> 
 
 netxen_nic.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)
  

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index fe9bff0..32032b0 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,7 +63,7 @@
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "3"
+#define NETXEN_NIC_BUILD_NO     "4"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
 #define _NETXEN_NIC_LINUX_SUBVERSION 2
@@ -137,7 +137,7 @@ extern struct workqueue_struct *netxen_w
 #define THIRD_PAGE_GROUP_SIZE  THIRD_PAGE_GROUP_END - THIRD_PAGE_GROUP_START
 
 #define MAX_RX_BUFFER_LENGTH		1760
-#define MAX_RX_JUMBO_BUFFER_LENGTH 	9046
+#define MAX_RX_JUMBO_BUFFER_LENGTH 	8062
 #define MAX_RX_LRO_BUFFER_LENGTH	((48*1024)-512)
 #define RX_DMA_MAP_LEN			(MAX_RX_BUFFER_LENGTH - 2)
 #define RX_JUMBO_DMA_MAP_LEN	\
@@ -199,9 +199,9 @@ enum {
 			(RCV_DESC_NORMAL)))
 
 #define MAX_CMD_DESCRIPTORS		1024
-#define MAX_RCV_DESCRIPTORS		32768
-#define MAX_JUMBO_RCV_DESCRIPTORS	4096
-#define MAX_LRO_RCV_DESCRIPTORS		2048
+#define MAX_RCV_DESCRIPTORS		16384
+#define MAX_JUMBO_RCV_DESCRIPTORS	1024
+#define MAX_LRO_RCV_DESCRIPTORS		64
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
 #define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
 #define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
