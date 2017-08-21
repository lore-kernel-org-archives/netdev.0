From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/7] ss: Make sure index variable is >= 0
Date: Mon, 21 Aug 2017 19:08:08 +0200
Message-ID: <20170821170813.29697-3-phil@nwl.cc>
References: <20170821170813.29697-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53819 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754184AbdHURI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:08:57 -0400
In-Reply-To: <20170821170813.29697-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This shouldn't happen but relying upon external data without checking
may lead to unexpected results.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 10360e5a04ff8..1ee02d73b2d7f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2004,7 +2004,7 @@ static void tcp_timer_print(struct tcpstat *s)
 		"unknown"
 	};
 
-	if (s->timer) {
+	if (s->timer >= 0) {
 		if (s->timer > 4)
 			s->timer = 5;
 		printf(" timer:(%s,%s,%d)",
-- 
2.13.1
