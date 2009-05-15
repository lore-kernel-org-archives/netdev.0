From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 1/5] de620: fix forgotten semicolon
Date: Sat, 16 May 2009 00:22:38 +0400
Message-ID: <1242418962-1272-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:20455 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbZEOUXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 16:23:04 -0400
Received: by fg-out-1718.google.com with SMTP id d23so204353fga.17
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:23:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems it always was here.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/de620.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index d52f34c..c5cd6e3 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -533,7 +533,7 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Start real output */
 
-	spin_lock_irqsave(&de620_lock, flags)
+	spin_lock_irqsave(&de620_lock, flags);
 	PRINTK(("de620_start_xmit: len=%d, bufs 0x%02x\n",
 		(int)skb->len, using_txbuf));
 
-- 
1.6.3

