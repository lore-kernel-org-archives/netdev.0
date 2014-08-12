From: Maks Naumov <maksqwe1@ukr.net>
Subject: [PATCH] irda: Fix rd_frame control field initialization in
 irlap_send_rd_frame()
Date: Tue, 12 Aug 2014 12:10:56 -0700
Message-ID: <1407870656.4174.9.camel@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from frv153.fwdcdn.com ([212.42.77.153]:40249 "EHLO
	frv153.fwdcdn.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbaHLTcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 15:32:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 4b2031adff2418d18f634be3655c2cebb51212e3 Mon Sep 17 00:00:00 2001
From: Maks Naumov <maksqwe1@ukr.net>
Date: Tue, 12 Aug 2014 11:28:41 -0700
Subject: [PATCH] irda: Fix rd_frame control field initialization in irlap_send_rd_frame()

Signed-off-by: Maks Naumov <maksqwe1@ukr.net>
---
 net/irda/irlap_frame.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 9ea0c93..a37998c 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -622,7 +622,7 @@ void irlap_send_rd_frame(struct irlap_cb *self)
 	frame = (struct rd_frame *)skb_put(tx_skb, 2);
 
 	frame->caddr = self->caddr;
-	frame->caddr = RD_RSP | PF_BIT;
+	frame->control = RD_RSP | PF_BIT;
 
 	irlap_queue_xmit(self, tx_skb);
 }
-- 
1.9.1
