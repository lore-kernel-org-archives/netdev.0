From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH iproute2 1/3] ip: fix and extend documentation
Date: Wed, 12 Aug 2015 22:04:06 +0200
Message-ID: <1439409848-26464-1-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Vadim Kochan <vadim4j@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Phil Sutter <psutter@redhat.com>,
	=?UTF-8?q?Pavel=20=C5=A0imerda?= <psimerda@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:46383 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbbHLUIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 16:08:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

 * Use unabbreviated `address` and `maddress`
 * Keep only `-n` and `-netns` for network namespace
---
 ip/ip.c       | 4 ++--
 man/man8/ip.8 | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/ip/ip.c b/ip/ip.c
index 0cf743f..e75447e 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -48,8 +48,8 @@ static void usage(void)
 	fprintf(stderr,
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
-"where  OBJECT :=3D { link | addr | addrlabel | route | rule | neigh |=
 ntable |\n"
-"                   tunnel | tuntap | maddr | mroute | mrule | monitor=
 | xfrm |\n"
+"where  OBJECT :=3D { link | address | addrlabel | route | rule | neig=
hbor | ntable |\n"
+"                   tunnel | tuntap | maddress | mroute | mrule | moni=
tor | xfrm |\n"
 "                   netns | l2tp | fou | tcp_metrics | token | netconf=
 }\n"
 "       OPTIONS :=3D { -V[ersion] | -s[tatistics] | -d[etails] | -r[es=
olve] |\n"
 "                    -h[uman-readable] | -iec |\n"
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 045414d..9da086d 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -19,8 +19,8 @@ ip \- show / manipulate routing, devices, policy rout=
ing and tunnels
=20
 .ti -8
 .IR OBJECT " :=3D { "
-.BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh=
 " | "\
- ntable " | " tunnel " | " tuntap " | " maddr " | "  mroute " | " mrul=
e " | "\
+.BR link " | " address " | " addrlabel " | " route " | " rule " | " ne=
igh " | "\
+ ntable " | " tunnel " | " tuntap " | " maddress " | "  mroute " | " m=
rule " | "\
  monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " }"
 .sp
=20
@@ -67,7 +67,7 @@ Output more detailed information.
=20
 .TP
 .BR "\-l" , " \-loops " <COUNT>
-Specify maximum number of loops the 'ip addr flush' logic
+Specify maximum number of loops the 'ip address flush' logic
 will attempt before giving up. The default is 10.
 Zero (0) means loop until all addresses are removed.
=20
@@ -143,7 +143,7 @@ use the system's name resolver to print DNS names i=
nstead of
 host addresses.
=20
 .TP
-.BR "\-n" , " \-net" , " \-netns " <NETNS>
+.BR "\-n" , " \-netns " <NETNS>
 switches
 .B ip
 to the specified network namespace
--=20
2.4.1
