From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCHv2 net-next 1/4] netxen_nic: disable minidump by default
Date: Wed,  9 May 2012 11:55:27 -0400
Message-ID: <1336578930-25141-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1336578930-25141-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58562 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751644Ab2EIQQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 12:16:27 -0400
In-Reply-To: <1336578930-25141-1-git-send-email-rajesh.borundia@qlogic.com>
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
1.6.3.3
