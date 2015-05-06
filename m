From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH iproute2] route: Add missing newline in helptext
Date: Wed,  6 May 2015 17:25:39 +0200
Message-ID: <0b8e5138df53bea652cb230d30f863b6fa6595ae.1430925856.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49870 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbEFPZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 11:25:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index e0a6159..8ac4369 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -77,7 +77,7 @@ static void usage(void)
 	fprintf(stderr, "             [ scope SCOPE ] [ metric METRIC ]\n");
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ via [ FAMILY ] ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
-	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | mpls | bridge | link ]");
+	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | mpls | bridge | link ]\n");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ] [ as [ to ] ADDRESS ]\n");
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
-- 
2.3.5
