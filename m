From: Neel Patel <neepatel@cisco.com>
Subject: [net-next PATCH 1/3] enic: Enable support for multiple hardware
	receive queues
Date: Fri, 03 Feb 2012 10:25:14 -0800
Message-ID: <20120203182514.9156.31915.stgit@savbu-pc100.cisco.com>
References: <20120203182439.9156.37052.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:29823 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757451Ab2BCSeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 13:34:44 -0500
In-Reply-To: <20120203182439.9156.37052.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>

This patch enables support for multiple receive queues. If multiple receive
queues are used ingress traffic is hashed into one of the receive queues based
on IP or TCP or both headers. The max number of supported receive queues per
vnic is 8.

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
--
 drivers/net/ethernet/cisco/enic/enic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index ee93a20..24bb088 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,13 +32,13 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.31"
+#define DRV_VERSION		"2.1.1.32"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
 
 #define ENIC_WQ_MAX		1
-#define ENIC_RQ_MAX		1
+#define ENIC_RQ_MAX		8
 #define ENIC_CQ_MAX		(ENIC_WQ_MAX + ENIC_RQ_MAX)
 #define ENIC_INTR_MAX		(ENIC_CQ_MAX + 2)
 
