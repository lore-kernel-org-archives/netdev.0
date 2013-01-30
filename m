From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 1/8] qlcnic: Fix sparse check endian warnings
Date: Wed, 30 Jan 2013 17:47:12 -0500
Message-ID: <1359586039-19051-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55867 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932069Ab3A3XIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 18:08:16 -0500
In-Reply-To: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index fdf3483..d00f628 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1018,7 +1018,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	if (htons(skb->protocol) == ETH_P_IPV6) {
+	if (ntohs(skb->protocol) == ETH_P_IPV6) {
 		ipv6h = (struct ipv6hdr *)skb->data;
 		th = (struct tcphdr *)(skb->data + sizeof(struct ipv6hdr));
 		length = (th->doff << 2) + lro_length;
-- 
1.7.1
