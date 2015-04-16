From: weiyj_lk@163.com
Subject: [PATCH -next] ethernet: remove unused including <linux/version.h>
Date: Thu, 16 Apr 2015 21:06:47 +0800
Message-ID: <1429189607-23459-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Stefan Wahren <stefan.wahren@i2se.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:44811 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097AbbDPNHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 09:07:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qualcomm/qca_spi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 4a42e96..f66641d 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -41,7 +41,6 @@
 #include <linux/skbuff.h>
 #include <linux/spi/spi.h>
 #include <linux/types.h>
-#include <linux/version.h>
 
 #include "qca_7k.h"
 #include "qca_debug.h"
