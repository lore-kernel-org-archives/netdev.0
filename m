From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 14/31] iw_cxgb4: default peer2peer mode to 1
Date: Mon, 10 Mar 2014 22:38:11 +0530
Message-ID: <1394471308-4304-15-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23264 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754304AbaCJRRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:17:44 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index c63dfe5..899be48 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -98,9 +98,9 @@ int c4iw_debug;
 module_param(c4iw_debug, int, 0644);
 MODULE_PARM_DESC(c4iw_debug, "Enable debug logging (default=0)");
 
-static int peer2peer;
+static int peer2peer = 1;
 module_param(peer2peer, int, 0644);
-MODULE_PARM_DESC(peer2peer, "Support peer2peer ULPs (default=0)");
+MODULE_PARM_DESC(peer2peer, "Support peer2peer ULPs (default=1)");
 
 static int p2p_type = FW_RI_INIT_P2PTYPE_READ_REQ;
 module_param(p2p_type, int, 0644);
-- 
1.8.4
