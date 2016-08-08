From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH 1/3] net: Remove unnecessary memset in __snmp6_fill_stats64
Date: Mon,  8 Aug 2016 18:22:20 +0800
Message-ID: <1470651742-15195-2-git-send-email-hejianet@gmail.com>
References: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
Cc: linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35477 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbcHHKWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 06:22:40 -0400
In-Reply-To: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

buff[] will be assigned later, so memset is not necessary.

Signed-off-by: Jia He <hejianet@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/addrconf.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab3e796..43fa8d0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4967,7 +4967,6 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
 
 	BUG_ON(pad < 0);
 
-	memset(buff, 0, sizeof(buff));
 	buff[0] = IPSTATS_MIB_MAX;
 
 	for_each_possible_cpu(c) {
-- 
2.5.0
