From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6] nf_conntrack_ecache.h: Fix missing braces
Date: Fri, 10 Oct 2008 11:08:45 +0800
Message-ID: <20081010030518.M86501@cooldavid.org>
References: <20081008.195524.235036900.davem@davemloft.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:46556 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbYJJDJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 23:09:17 -0400
In-Reply-To: <20081008.195524.235036900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David:

    This patch add missing braces of today's net-next-2.6:
    include/net/netfilter/nf_conntrack_ecache.h

    The patch is also available at:
    http://cooldavid.org/download/nf.net-next-2.6.20081010.patch

    Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/include/net/netfilter/nf_conntrack_ecache.h
b/include/net/netfilter/nf_conntrack_ecache.h
index 35f814c..11480e6 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -74,6 +74,7 @@ static inline void nf_ct_event_cache_flush(struct net *net) {}
 static inline int nf_conntrack_ecache_init(struct net *net)
 {
 	return 0;
+}
 
 static inline void nf_conntrack_ecache_fini(struct net *net)
 {

