From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 1/4] netxen_nic: disable minidump by default
Date: Tue, 8 May 2012 08:01:25 -0700
Message-ID: <1336489288-22347-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:50475
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755949Ab2EHPRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 11:17:40 -0400
In-Reply-To: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

disable fw dump by default at start up.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_ctx.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index f3c0057..c86ea12 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -229,7 +229,7 @@ netxen_setup_minidump(struct netxen_adapter *adapter)
 				adapter->mdump.md_template;
 	adapter->mdump.md_capture_buff = NULL;
 	adapter->mdump.fw_supports_md = 1;
-	adapter->mdump.md_enabled = 1;
+	adapter->mdump.md_enabled = 0;
 
 	return err;
 
-- 
1.7.3.3
