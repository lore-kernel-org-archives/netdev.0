From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH]: remove redundant sched/ in net/Makefile
Date: Thu, 09 Jul 2009 12:06:47 +0800
Message-ID: <4A556CD7.6090201@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:38121 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbZGIEG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 00:06:59 -0400
Received: by wa-out-1112.google.com with SMTP id j5so1147764wah.21
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2009 21:06:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant sched/ in net/Makefile.

sched/ is contained in previous:
obj-$(CONFIG_NET) += ethernet/ 802/ sched/ netlink/,
so the later
obj-$(CONFIG_NET_SCHED) += sched/
isn't necessary.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
Makefile | 1 -
1 file changed, 1 deletion(-)

diff --git a/net/Makefile b/net/Makefile
index ba324ae..1542e72 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -24,7 +24,6 @@ obj-y				+= ipv6/
 endif
 obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
-obj-$(CONFIG_NET_SCHED)		+= sched/
 obj-$(CONFIG_BRIDGE)		+= bridge/
 obj-$(CONFIG_NET_DSA)		+= dsa/
 obj-$(CONFIG_IPX)		+= ipx/

