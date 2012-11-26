From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next 2/2] tun: put correct method name in a debug message.
Date: Mon, 26 Nov 2012 10:07:41 +0200
Message-ID: <1353917261-2974-3-git-send-email-ramirose@gmail.com>
References: <1353917261-2974-1-git-send-email-ramirose@gmail.com>
Cc: maxk@qti.qualcomm.com, netdev@vger.kernel.org,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55628 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab2KZIIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 03:08:52 -0500
Received: by mail-wi0-f178.google.com with SMTP id hm6so3092179wib.1
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 00:08:52 -0800 (PST)
In-Reply-To: <1353917261-2974-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch puts the correct method name, tun_do_read, in a debug message.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/tun.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1dfb135..607a3a5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1296,7 +1296,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	struct sk_buff *skb;
 	ssize_t ret = 0;
 
-	tun_debug(KERN_INFO, tun, "tun_chr_read\n");
+	tun_debug(KERN_INFO, tun, "tun_do_read\n");
 
 	if (unlikely(!noblock))
 		add_wait_queue(&tfile->wq.wait, &wait);
-- 
1.7.11.7
