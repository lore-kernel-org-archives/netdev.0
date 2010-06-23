From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: remove ipv6_statistics
Date: Wed, 23 Jun 2010 14:51:25 +0200
Message-ID: <1277297485.2469.584.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Denis V.Lunev" <den@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36106 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab0FWMva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 08:51:30 -0400
Received: by wyi11 with SMTP id 11so724164wyi.19
        for <netdev@vger.kernel.org>; Wed, 23 Jun 2010 05:51:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9261e5370112 (ipv6: making ip and icmp statistics per/namespace)
forgot to remove ipv6_statistics variable.

commit bc417d99bf27 (ipv6: remove stale MIB definitions) took care of
icmpv6_statistics & icmpv6msg_statistics

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Denis V. Lunev <den@openvz.org>
CC: Alexey Dobriyan <adobriyan@gmail.com>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ipv6_sockglue.c |    2 --
 1 files changed, 2 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bd43f01..a7f66bc 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -55,8 +55,6 @@
 
 #include <asm/uaccess.h>
 
-DEFINE_SNMP_STAT(struct ipstats_mib, ipv6_statistics) __read_mostly;
-
 struct ip6_ra_chain *ip6_ra_chain;
 DEFINE_RWLOCK(ip6_ra_lock);
 


