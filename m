From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 01/20] ip: align help text with manpage
Date: Wed,  2 Mar 2016 19:19:49 +0100
Message-ID: <1456942808-15946-2-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35212 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755209AbcCBSU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:20:27 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
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
2.7.2
