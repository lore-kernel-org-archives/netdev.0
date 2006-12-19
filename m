From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] qla3xxx: Fixed rx checksum warning.
Date: Tue, 19 Dec 2006 10:22:39 -0800
Message-ID: <11665525601487-git-send-email-ron.mercer@qlogic.com>
References: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, benjamin.li@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:53404 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887AbWLSSdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 13:33:06 -0500
To: netdev@vger.kernel.org
In-Reply-To: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 24205c6..f384e40 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1879,7 +1879,7 @@ static void ql_process_macip_rx_intr(str
 		memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
 		skb2->ip_summed = CHECKSUM_NONE;
 	} else {
-		skb2->ip_summed = CHECKSUM_COMPLETE;
+		skb2->ip_summed = CHECKSUM_UNNECESSARY;
 		if (ib_ip_rsp_ptr->checksum & IB_IP_IOCB_RSP_3032_ICE) {
 			skb2->ip_summed = CHECKSUM_NONE;
 			printk(KERN_ERR
-- 
1.4.2.rc2-dirty

