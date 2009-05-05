From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [patch]tcp:fix the code indent
Date: Tue, 05 May 2009 19:01:29 +0800
Message-ID: <4A001C89.2050703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51322 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755045AbZEELDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 07:03:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5d427f8..ecab85f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1593,7 +1593,7 @@ process:
 #endif
 		{
 			if (!tcp_prequeue(sk, skb))
-			ret = tcp_v4_do_rcv(sk, skb);
+				ret = tcp_v4_do_rcv(sk, skb);
 		}
 	} else
 		sk_add_backlog(sk, skb);
-- 
1.5.3.4

