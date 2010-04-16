From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [net-next-2.6 PATCH 3/3 v2] ipv6: fix the comment of ip6_xmit()
Date: Fri, 16 Apr 2010 10:48:48 +0800
Message-ID: <4BC7D010.7080008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51449 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756271Ab0DPCuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 22:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip6_xmit() is used by upper transport protocol.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 141819f..5129a16 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -181,7 +181,7 @@ int ip6_output(struct sk_buff *skb)
 }
 
 /*
- *	xmit an sk_buff (used by TCP)
+ *	xmit an sk_buff (used by TCP, SCTP and DCCP)
  */
 
 int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
-- 
1.6.3.3
