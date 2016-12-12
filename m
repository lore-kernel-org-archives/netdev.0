From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv2 5/5] sh_eth: enable wake-on-lan for sh7763
Date: Mon, 12 Dec 2016 17:09:31 +0100
Message-ID: <20161212160931.6478-6-niklas.soderlund+renesas@ragnatech.se>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:54228 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753269AbcLLQK2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:10:28 -0500
In-Reply-To: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is based on public datasheet for sh7763 which shows it have the
same behavior and registers for WoL as other versions of sh_eth.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 927de77..6e80457 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -851,6 +851,7 @@ static struct sh_eth_cpu_data sh7763_data = {
 	.no_ade		= 1,
 	.tsu		= 1,
 	.irq_flags	= IRQF_SHARED,
+	.magic		= 1,
 };
 
 static struct sh_eth_cpu_data sh7619_data = {
-- 
2.10.2
