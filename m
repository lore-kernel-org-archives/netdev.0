From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 1/4] net: Use IS_ERR_OR_NULL().
Date: Wed, 23 Jan 2013 01:32:44 +0900
Message-ID: <50FEBF2C.4070902@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51853 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754308Ab3AVQcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/core/flow.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index b0901ee..43f7495 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -286,7 +286,7 @@ nocache:
 		else
 			fle->genid--;
 	} else {
-		if (flo && !IS_ERR(flo))
+		if (!IS_ERR_OR_NULL(flo))
 			flo->ops->delete(flo);
 	}
 ret_object:
-- 
1.7.9.5
