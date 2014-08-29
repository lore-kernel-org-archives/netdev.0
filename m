From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: make dsa_pack_type static
Date: Fri, 29 Aug 2014 12:42:07 -0700
Message-ID: <1409341327-22527-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Fengguang Wu <fengguang.wu@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47610 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383AbaH2Tmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 15:42:44 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so1072564pdi.22
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 12:42:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/dsa/dsa.c:624:20: sparse: symbol 'dsa_pack_type' was not declared.
Should it be static?

Fixes: 3e8a72d1dae374 ("net: dsa: reduce number of protocol hooks")
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 484f695351a7..61f145c44555 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -629,7 +629,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	return dst->ops->rcv(skb, dev, pt, orig_dev);
 }
 
-struct packet_type dsa_pack_type __read_mostly = {
+static struct packet_type dsa_pack_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_XDSA),
 	.func	= dsa_switch_rcv,
 };
-- 
1.9.1
