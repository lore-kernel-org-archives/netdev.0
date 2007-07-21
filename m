From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][29/37] Clean up duplicate includes in net/ipv6/
Date: Sat, 21 Jul 2007 17:03:44 +0200
Message-ID: <200707211703.44971.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Pekka Savola <pekkas@netcore.fi>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pedro Roque <roque@di.fc.ul.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:40095 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939419AbXGUPEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 11:04:42 -0400
Received: by ug-out-1314.google.com with SMTP id j3so799909ugf
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 08:04:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/ipv6/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d67fb1e..db50114 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -56,7 +56,6 @@
 #include <net/inet_ecn.h>
 #include <net/protocol.h>
 #include <net/xfrm.h>
-#include <net/addrconf.h>
 #include <net/snmp.h>
 #include <net/dsfield.h>
 #include <net/timewait_sock.h>
