From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv3 4/6] sh_eth: enable wake-on-lan for r8a7740/armadillo
Date: Mon,  9 Jan 2017 16:34:07 +0100
Message-ID: <20170109153409.13956-5-niklas.soderlund+renesas@ragnatech.se>
References: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-pm@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:52269 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938034AbdAIPfN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:35:13 -0500
In-Reply-To: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven reported WoL worked on his Armadillo board.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index afaf8785ed72..67cb6b3793ca 100644
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
2.11.0
