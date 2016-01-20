From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] net: change tcp_syn_retries documentation
Date: Wed, 20 Jan 2016 16:12:33 +0800
Message-ID: <34e957bf04e4742b1d6ea599ee1ea75349e6f1f2.1453277553.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36487 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933127AbcATIMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 03:12:40 -0500
Received: by mail-pa0-f66.google.com with SMTP id a20so62466pag.3
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 00:12:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation should be kept consistent with the code:

 static int tcp_syn_retries_max = MAX_TCP_SYNCNT;
 #define MAX_TCP_SYNCNT          127

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 Documentation/networking/ip-sysctl.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ceb44a0..73b36d7 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -594,7 +594,7 @@ tcp_fastopen - INTEGER
 
 tcp_syn_retries - INTEGER
 	Number of times initial SYNs for an active TCP connection attempt
-	will be retransmitted. Should not be higher than 255. Default value
+	will be retransmitted. Should not be higher than 127. Default value
 	is 6, which corresponds to 63seconds till the last retransmission
 	with the current initial RTO of 1second. With this the final timeout
 	for an active TCP connection attempt will happen after 127seconds.
-- 
2.1.0
