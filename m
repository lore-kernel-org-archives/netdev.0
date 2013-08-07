From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] net: wan: sbni: Fix incorrect placement of __initdata
Date: Wed,  7 Aug 2013 16:08:15 +0530
Message-ID: <1375871896-25821-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org, rl@hellgate.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:51111 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab3HGKzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 06:55:01 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so1260806pdc.33
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 03:55:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__initdata should be placed between the variable name and equal
sign for the variable to be placed in the intended section.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/wan/sbni.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index d43f4ef..5bbcb5e 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -176,7 +176,7 @@ static u32	mac[  SBNI_MAX_NUM_CARDS ] __initdata;
 
 #ifndef MODULE
 typedef u32  iarr[];
-static iarr __initdata *dest[5] = { &io, &irq, &baud, &rxl, &mac };
+static iarr *dest[5] __initdata = { &io, &irq, &baud, &rxl, &mac };
 #endif
 
 /* A zero-terminated list of I/O addresses to be probed on ISA bus */
-- 
1.7.9.5
