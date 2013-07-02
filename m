From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] l2tp: add missing .owner to struct pppox_proto
Date: Tue, 2 Jul 2013 09:02:07 +0800
Message-ID: <CAPgLHd8ehTkW5GwU7o_PYcSN66ovLcooc9kzJvM2P6Na-nDcJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: jchapman@katalix.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:52508 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755452Ab3GBBCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 21:02:09 -0400
Received: by mail-bk0-f44.google.com with SMTP id 6so414780bkj.31
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 18:02:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add missing .owner of struct pppox_proto. This prevents the
module from being removed from underneath its users.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/l2tp/l2tp_ppp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 8dec687..5ebee2d 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1793,7 +1793,8 @@ static const struct proto_ops pppol2tp_ops = {
 
 static const struct pppox_proto pppol2tp_proto = {
 	.create		= pppol2tp_create,
-	.ioctl		= pppol2tp_ioctl
+	.ioctl		= pppol2tp_ioctl,
+	.owner		= THIS_MODULE,
 };
 
 #ifdef CONFIG_L2TP_V3
