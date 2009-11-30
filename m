From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT] netxen: fix merge 9b963e5d0e01461099a
Date: Sun, 29 Nov 2009 20:01:15 -0800
Message-ID: <1259553675-14546-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45225 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753126AbZK3EBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 23:01:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch "fix memory initialization:5d521fd36de4e61" didn't got merge.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 6ee27a6..80a6674 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -528,6 +528,8 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter)
 				continue;
 			if (off == (ROMUSB_GLB + 0x1c)) /* MS clock */
 				continue;
+			if ((off & 0x0ff00000) == NETXEN_CRB_DDR_NET)
+				continue;
 			if (off == (NETXEN_CRB_PEG_NET_1 + 0x18) &&
 				!NX_IS_REVISION_P3P(adapter->ahw.revision_id))
 				buf[i].data = 0x1020;
-- 
1.6.0.2

