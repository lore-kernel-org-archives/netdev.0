From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] iptunnel: Fix compile error in ip/tunnel.c
Date: Mon, 21 Dec 2015 20:42:56 +0100
Message-ID: <20151221194131.636F061201@mail.nwl.cc>
References: <5677DBB6.3070008@iogearbox.net>
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55636 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbbLUTlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2015 14:41:32 -0500
In-Reply-To: <5677DBB6.3070008@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I repeatedly failed to get this right, so now I have to clean up my mess
afterwards.

Fixes: 7d6aadcd0a1dc ("ip{,6}tunnel: have a shared stats parser/printer")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/tunnel.c b/ip/tunnel.c
index 1dd8092..39f825b 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -208,7 +208,7 @@ void tnl_print_stats(const char *buf)
 		      tx_bytes, tx_packets, tx_errs, tx_drops,
 		      tx_fifo, tx_colls, tx_carrier, rx_multi;
 
-	if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
+	if (sscanf(buf, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
 	           &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
 	           &rx_fifo, &rx_frame, &rx_multi,
 	           &tx_bytes, &tx_packets, &tx_errs, &tx_drops,
-- 
2.5.3
