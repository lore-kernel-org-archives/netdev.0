From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 3/8] NetXen: Using correct CHECKSUM flag.
Date: Mon, 18 Dec 2006 05:51:58 -0800
Message-ID: <200612181351.kBIDpw4N012167@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4779 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754059AbWLROWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

netxen_nic_hw.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9147b60..f2850bf 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -376,7 +376,7 @@ void netxen_tso_check(struct netxen_adap
 		    ((skb->nh.iph)->ihl * sizeof(u32)) +
 		    ((skb->h.th)->doff * sizeof(u32));
 		netxen_set_cmd_desc_opcode(desc, TX_TCP_LSO);
-	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (skb->nh.iph->protocol == IPPROTO_TCP) {
 			netxen_set_cmd_desc_opcode(desc, TX_TCP_PKT);
 		} else if (skb->nh.iph->protocol == IPPROTO_UDP) {
