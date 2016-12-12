From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv2 3/5] sh_eth: enable wake-on-lan for r8a7740/armadillo
Date: Mon, 12 Dec 2016 17:09:29 +0100
Message-ID: <20161212160931.6478-4-niklas.soderlund+renesas@ragnatech.se>
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
Received: from smtp-4.sys.kth.se ([130.237.48.193]:54209 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752100AbcLLQK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:10:27 -0500
In-Reply-To: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven reported WoL worked on his Armadillo board.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 348ed22..fafde6f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -577,6 +577,7 @@ static struct sh_eth_cpu_data r8a7740_data = {
 	.tsu		= 1,
 	.select_mii	= 1,
 	.shift_rd0	= 1,
+	.magic		= 1,
 };
 
 /* There is CPU dependent code */
-- 
2.10.2
