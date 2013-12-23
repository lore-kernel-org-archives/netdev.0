From: Chen Weilong <chenweilong@huawei.com>
Subject: [resend patch net-next v3 5/7] ipv4: ERROR: do not initialise globals to 0 or NULL
Date: Mon, 23 Dec 2013 14:37:30 +0800
Message-ID: <1387780652-16232-6-git-send-email-chenweilong@huawei.com>
References: <1387780652-16232-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:34845 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757084Ab3LWGi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 01:38:57 -0500
In-Reply-To: <1387780652-16232-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/tcp_probe.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 8b97d71..1f2d376 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -38,7 +38,7 @@ MODULE_DESCRIPTION("TCP cwnd snooper");
 MODULE_LICENSE("GPL");
 MODULE_VERSION("1.1");
 
-static int port __read_mostly = 0;
+static int port __read_mostly;
 MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
@@ -46,7 +46,7 @@ static unsigned int bufsize __read_mostly = 4096;
 MODULE_PARM_DESC(bufsize, "Log buffer size in packets (4096)");
 module_param(bufsize, uint, 0);
 
-static unsigned int fwmark __read_mostly = 0;
+static unsigned int fwmark __read_mostly;
 MODULE_PARM_DESC(fwmark, "skb mark to match (0=no mark)");
 module_param(fwmark, uint, 0);
 
-- 
1.7.12
