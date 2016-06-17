From: weiyj_lk@163.com
Subject: [PATCH] gtp: remove unused including <linux/version.h>
Date: Fri, 17 Jun 2016 17:33:30 +0000
Message-ID: <1466184810-4761-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:46252 "EHLO m12-11.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809AbcFQRe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 13:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/gtp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 4e976a0..97e0cbc 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -16,7 +16,6 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/skbuff.h>
 #include <linux/udp.h>
 #include <linux/rculist.h>
