From: weiyj_lk@163.com
Subject: [PATCH -next] tipc: remove duplicated include from socket.c
Date: Mon, 28 Jul 2014 21:30:14 +0800
Message-ID: <1406554214-30460-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:48690 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbaG1Nah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 09:30:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/tipc/socket.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 8c5600c..7ce96c7 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -40,7 +40,6 @@
 #include "node.h"
 #include "link.h"
 #include <linux/export.h>
-#include "link.h"
 
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
