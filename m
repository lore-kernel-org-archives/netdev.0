From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 1/2] ipv6: export symbol datagram_recv_ctl in datagram.c
Date: Mon, 28 Jan 2013 10:48:53 +0000
Message-ID: <1359370134-29875-2-git-send-email-tparkin@katalix.com>
References: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49841 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606Ab3A1KtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 05:49:10 -0500
In-Reply-To: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modules using datagram_send_ctl for ancilliary data in the send path should be
using datagram_recv_ctl for ancilliary data in the recv path.  Export
datagram_recv_ctl accordingly.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Chris Elston <celston@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/ipv6/datagram.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 33be363..f8a7b51 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -598,6 +598,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(datagram_recv_ctl);
 
 int datagram_send_ctl(struct net *net, struct sock *sk,
 		      struct msghdr *msg, struct flowi6 *fl6,
-- 
1.7.9.5
