From: Duan Jiong <djduanjiong@gmail.com>
Subject: [RESEND] lpc_eth: remove duplicated include
Date: Mon, 16 Jul 2012 20:29:05 +0800
Message-ID: <50040911.5050107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41287 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab2GPM3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 08:29:10 -0400
Received: by pbbrp8 with SMTP id rp8so9992120pbb.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 05:29:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include <linux/delay.h> in
drivers/net/ethernet/nxp/lpc_eth.c

Signed-off-by: Duan Jiong<djduanjiong@gmail.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 083d671..a1fe179 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -44,7 +44,6 @@
 #include <linux/of_net.h>
 #include <linux/types.h>
 
-#include <linux/delay.h>
 #include <linux/io.h>
 #include <mach/board.h>
 #include <mach/platform.h>
-- 
1.7.9.5
