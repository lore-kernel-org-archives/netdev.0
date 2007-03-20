From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 07/31] [ATM] idt77252: Fix double kfree_skb on failure in push_rx_skb
Date: Tue, 20 Mar 2007 19:55:09 -0300
Message-ID: <20070320225509.GT17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:25953 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbXCTWzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:55:13 -0400
Received: by wx-out-0506.google.com with SMTP id h31so60697wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:55:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/atm/idt77252.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 20f2a3a..057efbc 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1839,7 +1839,6 @@ push_rx_skb(struct idt77252_dev *card, struct sk_buff *skb, int queue)
 		skb_put(skb, SAR_FB_SIZE_3);
 		break;
 	default:
-		dev_kfree_skb(skb);
 		return -1;
 	}
 
-- 
1.5.0.3

