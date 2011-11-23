From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] route: struct rtable can be const in rt_is_input_route
 and rt_is_output_route
Date: Wed, 23 Nov 2011 13:14:15 +0100
Message-ID: <20111123121414.GD6348@secunet.com>
References: <20111123121213.GA6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53461 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754352Ab1KWMOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 07:14:16 -0500
Content-Disposition: inline
In-Reply-To: <20111123121213.GA6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/route.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index db7b343..91855d1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -71,12 +71,12 @@ struct rtable {
 	struct fib_info		*fi; /* for client ref to shared metrics */
 };
 
-static inline bool rt_is_input_route(struct rtable *rt)
+static inline bool rt_is_input_route(const struct rtable *rt)
 {
 	return rt->rt_route_iif != 0;
 }
 
-static inline bool rt_is_output_route(struct rtable *rt)
+static inline bool rt_is_output_route(const struct rtable *rt)
 {
 	return rt->rt_route_iif == 0;
 }
-- 
1.7.0.4
