From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 2/2] sh_eth: Enable Rx descriptor word 0 shift for r8a7790
Date: Wed, 28 Aug 2013 09:43:09 +0900
Message-ID: <1377650589-20960-3-git-send-email-horms+renesas@verge.net.au>
References: <1377650589-20960-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Kouei Abe <kouei.abe.cp@renesas.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56248 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab3H1And (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 20:43:33 -0400
In-Reply-To: <1377650589-20960-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kouei Abe <kouei.abe.cp@renesas.com>

This corrects an oversight when r8a7790 support was added to sh_eth.

Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index f386a8f..095ca8e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -416,6 +416,7 @@ static struct sh_eth_cpu_data r8a7790_data = {
 	.tpauser	= 1,
 	.hw_swap	= 1,
 	.rmiimode	= 1,
+	.shift_rd0	= 1,
 };
 
 static void sh_eth_set_rate_sh7724(struct net_device *ndev)
-- 
1.8.3.2
