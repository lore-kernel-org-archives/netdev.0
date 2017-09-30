From: Lin Zhang <xiaolou4617@gmail.com>
Subject: [PATCH v2 1/2] net: phonet: mark header_ops as const
Date: Sat, 30 Sep 2017 17:39:36 +0800
Message-ID: <1506764376-6549-1-git-send-email-xiaolou4617@gmail.com>
Cc: netdev@vger.kernel.org, courmisch@gmail.com,
        Lin Zhang <xiaolou4617@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32801 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdI3Jjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 05:39:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id m28so1143972pfi.0
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 02:39:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
---
 net/phonet/af_phonet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index f925753..b12142e 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -149,7 +149,7 @@ static int pn_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 	return 1;
 }
 
-struct header_ops phonet_header_ops = {
+const struct header_ops phonet_header_ops = {
 	.create = pn_header_create,
 	.parse = pn_header_parse,
 };
-- 
1.8.3.1
