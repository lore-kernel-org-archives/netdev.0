From: pablo@netfilter.org
Subject: [PATCH 21/25] ipvs: ip_vs_proto: local functions should not be exposed globally
Date: Tue,  8 May 2012 20:38:19 +0200
Message-ID: <1336502303-1722-22-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39512 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756662Ab2EHSkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:40:21 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: H Hartley Sweeten <hartleys@visionengravers.com>

Functions not referenced outside of a source file should be marked
static to prevent it from being exposed globally.

This quiets the sparse warnings:

warning: symbol '__ipvs_proto_data_get' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index e91c898..50d82186 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -156,7 +156,7 @@ EXPORT_SYMBOL(ip_vs_proto_get);
 /*
  *	get ip_vs_protocol object data by netns and proto
  */
-struct ip_vs_proto_data *
+static struct ip_vs_proto_data *
 __ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 {
 	struct ip_vs_proto_data *pd;
-- 
1.7.9.5
