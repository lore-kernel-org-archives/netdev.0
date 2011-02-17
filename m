From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 2/3] enic: Clean up: Remove a not needed #ifdef
Date: Thu, 17 Feb 2011 10:53:17 -0800
Message-ID: <20110217185317.2476.75828.stgit@savbu-pc100.cisco.com>
References: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:40415 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757718Ab1BQSxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 13:53:17 -0500
In-Reply-To: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>



Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 5f4eb45..2ac891b 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.7"
+#define DRV_VERSION		"2.1.1.8"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a625a0e..d1aa807 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2223,9 +2223,7 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 	.ndo_tx_timeout		= enic_tx_timeout,
 	.ndo_set_vf_port	= enic_set_vf_port,
 	.ndo_get_vf_port	= enic_get_vf_port,
-#ifdef IFLA_VF_MAX
 	.ndo_set_vf_mac		= enic_set_vf_mac,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= enic_poll_controller,
 #endif

