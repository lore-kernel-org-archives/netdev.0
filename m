From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] af_packet: Quiet sparse noise about using plain integer as NULL pointer
Date: Tue, 7 Aug 2012 10:27:10 +0800
Message-ID: <1344306430-30450-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57776 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932552Ab2HGC1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 22:27:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quiets the sparse warning:
warning: Using plain integer as NULL pointer

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/packet/af_packet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ceaca7c..f016f66 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1079,7 +1079,7 @@ static void *packet_current_rx_frame(struct packet_sock *po,
 	default:
 		WARN(1, "TPACKET version not supported\n");
 		BUG();
-		return 0;
+		return NULL;
 	}
 }
 
-- 
1.7.1
