From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/2] NetXen: Fix NetXen driver ping on system-p
Date: Thu, 17 May 2007 06:52:25 -0700
Message-ID: <200705171352.l4HDqPL9023075@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:18329 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754331AbXEQNwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 09:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix for driver on System-p
This patch will fix a ping issue on system-p

Signed-off by: Milan Bag <mbag@netxen.com>
Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
Signed-by: Mithlesh Thukral <mithlesh@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index cf0e96a..a368924 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1216,7 +1216,7 @@ u32 netxen_process_rcv_ring(struct netxe
 		/* Window = 1 */
 		writel(consumer,
 		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[ctxid].
+					    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
 	}
 
