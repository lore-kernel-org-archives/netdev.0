From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] net: add missing prefetch.h include
Date: Sun, 22 May 2011 18:55:10 +0200
Message-ID: <20110522165510.GB2504@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:60872 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920Ab1EVQzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 12:55:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Fixes build errors on s390 and probably other archs as well:

In file included from net/ipv4/ip_forward.c:32:0:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141:2: error: implicit declaration of function 'prefetch'

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

 include/linux/skbuff.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 79aafbb..8276815 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -28,6 +28,7 @@
 #include <net/checksum.h>
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
+#include <linux/prefetch.h>
 #include <linux/hrtimer.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
