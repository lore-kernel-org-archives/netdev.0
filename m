From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] mISDN: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 21:12:27 +0800
Message-ID: <CAPgLHd8TSXfQtVc3JSBKuXQTOFvyLoUgzsXw=wLkt2rHM9aALg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:36079 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137Ab2H1NM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:12:28 -0400
Received: by mail-qc0-f174.google.com with SMTP id o28so3331648qcr.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 06:12:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/isdn/mISDN/socket.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index abe2d69..f677724 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -243,8 +243,7 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 done:
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 	release_sock(sk);
 	return err;
 }
