From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Remove bogus WARN_ON() in Proxy-NA handling.
Date: Fri, 13 Oct 2006 15:52:01 +0900 (JST)
Message-ID: <20061013.155201.118357599.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37387 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751204AbWJMGtc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 02:49:32 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Remove bogus WARN_ON in Proxy-NA handling.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>c

---
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0304b5f..41a8a5f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -967,8 +967,6 @@ static void ndisc_recv_na(struct sk_buff
 		    ipv6_devconf.forwarding && ipv6_devconf.proxy_ndp &&
 		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
 			/* XXX: idev->cnf.prixy_ndp */
-			WARN_ON(skb->dst != NULL &&
-				((struct rt6_info *)skb->dst)->rt6i_idev);
 			goto out;
 		}
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
