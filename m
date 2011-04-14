From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH] net: export skb_clone_tx_timestamp
Date: Thu, 14 Apr 2011 19:35:02 +0200
Message-ID: <20110414173502.GA15244@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64675 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755344Ab1DNRfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 13:35:14 -0400
Received: by fxm17 with SMTP id 17so1331413fxm.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 10:35:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAC drivers compiled as modules may well want to call this function via
the skb_tx_timestamp inline function. This patch exports the function in
order to let this happen.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 net/core/timestamping.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 7e7ca37..3b00a6b 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -68,6 +68,7 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 		break;
 	}
 }
+EXPORT_SYMBOL_GPL(skb_clone_tx_timestamp);
 
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps)
-- 
1.7.0.4

