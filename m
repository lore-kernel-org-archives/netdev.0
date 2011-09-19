From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 1/2] netxen: Fix vhdr_len in case of non vlan packets.
Date: Mon, 19 Sep 2011 11:49:51 -0700
Message-ID: <1316458192-8691-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1316458192-8691-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:42525 "EHLO
	TX2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756451Ab1ISTAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 15:00:50 -0400
In-Reply-To: <1316458192-8691-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Set vlan header length to zero.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index d6c6357..a8259cc 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1620,7 +1620,7 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	int index;
 	u16 lro_length, length, data_offset;
 	u32 seq_number;
-	u8 vhdr_len;
+	u8 vhdr_len = 0;
 
 	if (unlikely(ring > adapter->max_rds_rings))
 		return NULL;
-- 
1.6.3.3
