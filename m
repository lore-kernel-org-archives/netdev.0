From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Subject: [PATCH] smc91x Hitachi Solution Engine (SuperH) Support
Date: Wed, 19 Sep 2007 21:07:52 +0900
Message-ID: <20070919210752.5b211317.iwamatsu@nigauri.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, iwamatsu@nigauri.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from l247104.ppp.asahi-net.or.jp ([218.219.247.104]:47981 "EHLO
	ns.nigauri.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbXISMeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 08:34:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi, all.

This patch supports Hitachi Solution Engine (SuperH) of smc91x. 
Please apply this patch .

regards,
 Nobuhiro

-- 
Nobuhiro Iwamatsu
	E-Mail : iwamatsu@nigauri.org
	GPG ID : 3170EBE9 

Signed-off-by:	Nobuhiro Iwamatsu <iwamatsu@nigauri.org>

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 6ff3a16..af9e6bf 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -284,6 +284,7 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #elif   defined(CONFIG_SUPERH)
 
 #ifdef CONFIG_SOLUTION_ENGINE
+#define SMC_IRQ_FLAGS		(0)
 #define SMC_CAN_USE_8BIT       0
 #define SMC_CAN_USE_16BIT      1
 #define SMC_CAN_USE_32BIT      0
