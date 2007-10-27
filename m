From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] tcp v6: fix softnet build breakage
Date: Fri, 26 Oct 2007 23:42:40 -0400
Message-ID: <20071027034240.GA13016@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37794 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbXJ0Dml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 23:42:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


net/ipv6/tcp_ipv6.c: In function 'tcp_v6_rcv':
net/ipv6/tcp_ipv6.c:1736: error: implicit declaration of function
'get_softnet_dma'
net/ipv6/tcp_ipv6.c:1736: warning: assignment makes pointer from integer
without a cast

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 06fa4ba..8520802 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -59,6 +59,7 @@
 #include <net/snmp.h>
 #include <net/dsfield.h>
 #include <net/timewait_sock.h>
+#include <net/netdma.h>
 
 #include <asm/uaccess.h>
 
