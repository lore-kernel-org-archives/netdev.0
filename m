From: Christian Hesse <list@eworm.de>
Subject: [PATCH 1/1] use buf, not (non-existent) ptr
Date: Mon, 21 Dec 2015 14:08:18 +0100
Message-ID: <1450703298-21675-1-git-send-email-list@eworm.de>
Cc: Christian Hesse <mail@eworm.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:40745 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbbLUNRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 08:17:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Hesse <mail@eworm.de>

Shared code was moved to a function, but variable name has not been
updated. Use buf (passed to the function) instead of ptr.

This fixes regressen from upstream commit
7d6aadcd0a1dc795d72e1ab311aee333c763fe71.

Signed-off-by: Christian Hesse <mail@eworm.de>
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
2.6.4
