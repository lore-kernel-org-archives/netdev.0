From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: min_pmtu default is 552
Date: Tue, 08 Nov 2011 20:10:28 +0100
Message-ID: <1320779428.2588.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60958 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712Ab1KHTKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:10:42 -0500
Received: by wwi36 with SMTP id 36so1250692wwi.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 11:10:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small fix in Documentation, since min_pmtu is 512 + 20 + 20 = 552

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index cb7f314..f049a1c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -20,7 +20,7 @@ ip_no_pmtu_disc - BOOLEAN
 	default FALSE
 
 min_pmtu - INTEGER
-	default 562 - minimum discovered Path MTU
+	default 552 - minimum discovered Path MTU
 
 route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
