From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/9] net: phy: dp83640: fix checkpath error
Date: Tue, 17 Dec 2013 21:38:07 -0800
Message-ID: <1387345093-14168-4-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:47743 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3LRFi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:26 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so7738648oag.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:26 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/dp83640.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 7490b6c..547725f 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -851,8 +851,8 @@ static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
 
 	seqid = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
 
-	return (rxts->msgtype == (*msgtype & 0xf) &&
-		rxts->seqid   == ntohs(*seqid));
+	return rxts->msgtype == (*msgtype & 0xf) &&
+		rxts->seqid   == ntohs(*seqid);
 }
 
 static void dp83640_free_clocks(void)
-- 
1.8.3.2
