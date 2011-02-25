From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 2/7] dccp: newdp is declared/assigned but never be used
Date: Fri, 25 Feb 2011 16:45:16 +0100
Message-ID: <1298648721-3026-2-git-send-email-hagen@jauu.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57597 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755488Ab1BYPxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:25 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declaration and assignment of newdp is removed. Usage of dccp_sk()
exhibit no side effects.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/dccp/ipv6.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index dca711d..460d545 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -484,7 +484,6 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	struct inet6_request_sock *ireq6 = inet6_rsk(req);
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct inet_sock *newinet;
-	struct dccp_sock *newdp;
 	struct dccp6_sock *newdp6;
 	struct sock *newsk;
 	struct ipv6_txoptions *opt;
@@ -498,7 +497,6 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 			return NULL;
 
 		newdp6 = (struct dccp6_sock *)newsk;
-		newdp = dccp_sk(newsk);
 		newinet = inet_sk(newsk);
 		newinet->pinet6 = &newdp6->inet6;
 		newnp = inet6_sk(newsk);
@@ -578,7 +576,6 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	newdp6 = (struct dccp6_sock *)newsk;
 	newinet = inet_sk(newsk);
 	newinet->pinet6 = &newdp6->inet6;
-	newdp = dccp_sk(newsk);
 	newnp = inet6_sk(newsk);
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
-- 
1.7.2.3

