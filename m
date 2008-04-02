From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.26] [IPV6] RAW: Remove ancient comment.
Date: Wed, 02 Apr 2008 15:36:23 +0900 (JST)
Message-ID: <20080402.153623.91891399.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59944 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbYDBGes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 02:34:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/raw.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index c1e495f..aae6ced 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -168,11 +168,6 @@ static int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 
-	/*
-	 *	The first socket found will be delivered after
-	 *	delivery to transport protocols.
-	 */
-
 	if (sk == NULL)
 		goto out;
 
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
