From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 06/20] iproute: TYPE keyword is not optional, fix help text accordingly
Date: Wed,  2 Mar 2016 19:19:54 +0100
Message-ID: <1456942808-15946-7-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42502 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756057AbcCBSVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:21:36 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a bit pedantic, but brackets ([]) show optional values and since
TYPE must not become empty, they're not suited to surround the type
keyword choices. Use curly braces instead.

Also add some missing whitespace to the parameter list above.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 051fc12d197eb..5b954478cfb7f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -82,13 +82,13 @@ static void usage(void)
 	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | mpls | bridge | link ]\n");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ] [ as [ to ] ADDRESS ]\n");
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
-	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
+	fprintf(stderr, "           [ window NUMBER ] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
 	fprintf(stderr, "           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]\n");
 	fprintf(stderr, "           [ pref PREF ] [ expires TIME ]\n");
-	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
-	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
+	fprintf(stderr, "TYPE := { unicast | local | broadcast | multicast | throw |\n");
+	fprintf(stderr, "          unreachable | prohibit | blackhole | nat }\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
 	fprintf(stderr, "SCOPE := [ host | link | global | NUMBER ]\n");
 	fprintf(stderr, "NHFLAGS := [ onlink | pervasive ]\n");
-- 
2.7.2
