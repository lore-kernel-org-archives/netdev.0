From: pablo@netfilter.org
Subject: [PATCH 20/25] ipvs: ip_vs_ftp: local functions should not be exposed globally
Date: Tue,  8 May 2012 09:49:49 +0200
Message-ID: <1336463394-3119-21-git-send-email-pablo@netfilter.org>
References: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41242 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757365Ab2EHHuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 03:50:37 -0400
In-Reply-To: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: H Hartley Sweeten <hartleys@visionengravers.com>

Functions not referenced outside of a source file should be marked
static to prevent it from being exposed globally.

This quiets the sparse warnings:

warning: symbol 'ip_vs_ftp_init' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ftp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index debb8c7..091bec9 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -483,7 +483,7 @@ static struct pernet_operations ip_vs_ftp_ops = {
 	.exit = __ip_vs_ftp_exit,
 };
 
-int __init ip_vs_ftp_init(void)
+static int __init ip_vs_ftp_init(void)
 {
 	int rv;
 
-- 
1.7.9.5
