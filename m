From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 32/51] ss: Make sure index variable is >= 0
Date: Sat, 12 Aug 2017 14:04:51 +0200
Message-ID: <20170812120510.28750-33-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37939 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752637AbdHLMKY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:10:24 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This shouldn't happen but relying upon external data without checking
may lead to unexpected results.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index d767b1103ea81..4d2f75b571ea6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2003,7 +2003,7 @@ static void tcp_timer_print(struct tcpstat *s)
 		"unknown"
 	};
 
-	if (s->timer) {
+	if (s->timer >= 0) {
 		if (s->timer > 4)
 			s->timer = 5;
 		printf(" timer:(%s,%s,%d)",
-- 
2.13.1
