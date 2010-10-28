From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/2] vmxnet: trivial annotation of protocol constant
Date: Wed, 27 Oct 2010 20:12:35 -0700
Message-ID: <1288235555-24675-2-git-send-email-harvey.harrison@gmail.com>
References: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com>
Cc: netdev@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:46154 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887Ab0J1DMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 23:12:44 -0400
Received: by gwj21 with SMTP id 21so933993gwj.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 20:12:43 -0700 (PDT)
In-Reply-To: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed by sparse:
drivers/net/vmxnet3/vmxnet3_drv.c:876:38: warning: cast from restricted __be16
drivers/net/vmxnet3/vmxnet3_drv.c:876:38: warning: cast from restricted __be16
drivers/net/vmxnet3/vmxnet3_drv.c:876:24: warning: restricted __be16 degrades to integer

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index e3658e1..21314e0 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -873,7 +873,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) +
 		skb_shinfo(skb)->nr_frags + 1;
 
-	ctx.ipv4 = (skb->protocol == __constant_ntohs(ETH_P_IP));
+	ctx.ipv4 = (skb->protocol == cpu_to_be16(ETH_P_IP));
 
 	ctx.mss = skb_shinfo(skb)->gso_size;
 	if (ctx.mss) {
-- 
1.7.1

