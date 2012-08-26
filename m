From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] airo: remove duplicated include from airo.c
Date: Sun, 26 Aug 2012 09:55:20 +0800
Message-ID: <CAPgLHd9koRABK68bnEUGx+9CnvB78GxVaMbzVrPULwaNNpkHOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:58874 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986Ab2HZBzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 21:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/airo.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index f9f15bb..f4c1b8e 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -87,7 +87,6 @@ static struct pci_driver airo_driver = {
 /* Include Wireless Extension definition and check version - Jean II */
 #include <linux/wireless.h>
 #define WIRELESS_SPY		/* enable iwspy support */
-#include <net/iw_handler.h>	/* New driver API */
 
 #define CISCO_EXT		/* enable Cisco extensions */
 #ifdef CISCO_EXT
