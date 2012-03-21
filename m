From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] enable automatic module loading for l2tp_ppp
Date: Tue, 20 Mar 2012 20:01:21 -0400
Message-ID: <20120321000121.GA3133@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:34273 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab2CUABW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 20:01:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When L2TP is configured as a module, requests for L2TP sockets do not result
in the l2tp_ppp module being loaded.  Fix this by adding the appropriate
MODULE_ALIAS to be recognized by pppox's request_module() call.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/l2tp/l2tp_ppp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 9b07191..1addd9f 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1845,3 +1845,4 @@ MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("PPP over L2TP over UDP");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(PPPOL2TP_DRV_VERSION);
+MODULE_ALIAS("pppox-proto-" __stringify(PX_PROTO_OL2TP));
-- 
1.7.4.1
