From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH v2 2/3] ipv6: export ip6_datagram_recv_ctl
Date: Wed, 30 Jan 2013 14:21:25 +0000
Message-ID: <1359555686-21588-3-git-send-email-tparkin@katalix.com>
References: <1359555686-21588-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34798 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492Ab3A3OVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 09:21:34 -0500
In-Reply-To: <1359555686-21588-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_datagram_recv_ctl and ip6_datagram_send_ctl are used for handling IPv6
ancillary data.  Since ip6_datagram_send_ctl is already publicly exported for
use in modules, ip6_datagram_recv_ctl should also be available to support
ancillary data in the receive path.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/ipv6/datagram.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index ecdea449..8f6cc15a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -599,6 +599,7 @@ int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ip6_datagram_recv_ctl);
 
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 		      struct msghdr *msg, struct flowi6 *fl6,
-- 
1.7.9.5
