From: pablo@netfilter.org
Subject: [PATCH 25/25] netfilter: properly annotate ipv4_netfilter_{init,fini}()
Date: Tue,  4 Sep 2012 01:54:12 +0200
Message-ID: <1346716452-3080-26-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37187 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932092Ab2ICX4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:56:11 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Beulich <JBeulich@suse.com>

Despite being just a few bytes of code, they should still have proper
annotations.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index f1643c0..4c0cf63 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -188,12 +188,12 @@ static const struct nf_afinfo nf_ip_afinfo = {
 	.route_key_size		= sizeof(struct ip_rt_info),
 };
 
-static int ipv4_netfilter_init(void)
+static int __init ipv4_netfilter_init(void)
 {
 	return nf_register_afinfo(&nf_ip_afinfo);
 }
 
-static void ipv4_netfilter_fini(void)
+static void __exit ipv4_netfilter_fini(void)
 {
 	nf_unregister_afinfo(&nf_ip_afinfo);
 }
-- 
1.7.10.4
