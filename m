From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 01/10] net: export time stamp utility function for Ethernet MAC drivers
Date: Sun, 12 Jun 2011 14:18:58 +0200
Message-ID: <9fe0d20706c50434be4dfcbc5806709cf62a78ed.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46427 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab1FLMTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:19:12 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so3125460bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:19:11 -0700 (PDT)
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network stack provides the function, skb_clone_tx_timestamp().
Ethernet MAC drivers can call this via the transmit time stamping
hook, skb_tx_timestamp(). This commit exports the clone function so
that drivers using it can be compiled as modules.

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

