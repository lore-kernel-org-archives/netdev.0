From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [net-2.6] [IPV6]: Use appropriate sock tclass setting for routing
 lookup.
Date: Mon, 14 Apr 2008 15:38:12 +0900 (JST)
Message-ID: <20080414.153812.32704570.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33480 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbYDNGhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/inet_ecn.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index ba33db0..7040a78 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -47,7 +47,7 @@ static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
     } while (0)
 
 #define	IP6_ECN_flow_xmit(sk, label) do {				\
-	if (INET_ECN_is_capable(inet_sk(sk)->tos))			\
+	if (INET_ECN_is_capable(inet6_sk(sk)->tclass))			\
 		(label) |= htonl(INET_ECN_ECT_0 << 20);			\
     } while (0)
 
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
