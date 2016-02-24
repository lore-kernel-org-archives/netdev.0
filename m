From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 01/20] ip: align help text with manpage
Date: Wed, 24 Feb 2016 09:21:14 +0100
Message-ID: <1456302093-697-2-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45603 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758073AbcBXIXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:23:40 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although the ip command accepts both "neighbor" and "neighbour" as
subcommand, I assume it's sufficient to list it in help text as just
"neigh" like ip.8 does.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ip.c b/ip/ip.c
index eea00b822088e..123f18133a2e5 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -49,7 +49,7 @@ static void usage(void)
 	fprintf(stderr,
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
-"where  OBJECT := { link | address | addrlabel | route | rule | neighbor | ntable |\n"
+"where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |\n"
 "                   netns | l2tp | fou | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
-- 
2.6.4
