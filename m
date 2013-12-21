From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next] sctp: fix missing include file
Date: Fri, 20 Dec 2013 18:51:10 -0800
Message-ID: <20131221025110.9758.12509.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: vyasevich@gmail.com, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:42412 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab3LUCvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 21:51:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile error reported by Jim Davis on netdev.

ip6_sk_accept_pmtu() needs net/ip6_route.h

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 net/sctp/input.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 042ec6c..479ee19 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -48,6 +48,7 @@
 #include <linux/time.h> /* For struct timeval */
 #include <linux/slab.h>
 #include <net/ip.h>
+#include <net/ip6_route.h>
 #include <net/icmp.h>
 #include <net/snmp.h>
 #include <net/sock.h>
