From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/20] netfilter: ipset: remove duplicate define
Date: Mon,  4 Nov 2013 22:50:37 +0100
Message-ID: <1383601842-4570-16-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55719 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab3KDVvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:51:01 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>

This patch removes a duplicate define from
net/netfilter/ipset/ip_set_hash_gen.h

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 2f80c74..be6932a 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -234,7 +234,6 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_uadt		IPSET_TOKEN(MTYPE, _uadt)
 #define mtype			MTYPE
 
-#define mtype_elem		IPSET_TOKEN(MTYPE, _elem)
 #define mtype_add		IPSET_TOKEN(MTYPE, _add)
 #define mtype_del		IPSET_TOKEN(MTYPE, _del)
 #define mtype_test_cidrs	IPSET_TOKEN(MTYPE, _test_cidrs)
-- 
1.7.10.4
