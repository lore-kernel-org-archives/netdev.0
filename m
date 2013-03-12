From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: Mention the 'up' argument in documentation
Date: Tue, 12 Mar 2013 16:56:02 +0100
Message-ID: <1363103762-1673-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab3CLP4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 11:56:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both ip-link and ip-address support the 'up' argument, however this
isn't documented in neither their help outputs or ip-address' manpage.
This patch fixes that.

Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
Reported-by: Ji=C5=99=C3=AD Popelka <jpopelka@redhat.com>
---
 ip/ipaddress.c           | 2 +-
 ip/iplink.c              | 2 +-
 man/man8/ip-address.8.in | 4 ++++
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index cff503f..54c394b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -71,7 +71,7 @@ static void usage(void)
 	fprintf(stderr, "                                                    =
  [ CONFFLAG-LIST ]\n");
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
 	fprintf(stderr, "       ip addr {show|save|flush} [ dev STRING ] [ sc=
ope SCOPE-ID ]\n");
-	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIS=
T ] [ label PATTERN ]\n");
+	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIS=
T ] [ label PATTERN ] [up]\n");
 	fprintf(stderr, "       ip addr {showdump|restore}\n");
 	fprintf(stderr, "IFADDR :=3D PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
diff --git a/ip/iplink.c b/ip/iplink.c
index ad33611..5c7b43c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -79,7 +79,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ spoofchk { on | off} ] ] \n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
-	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ]\n");
+	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n"=
);
=20
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 63bf9cb..3cfc56a 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -163,6 +163,10 @@ only list addresses with labels matching the
 is a usual shell style pattern.
=20
 .TP
+.B up
+only list running interfaces.
+
+.TP
 .BR dynamic " and " permanent
 (IPv6 only) only list addresses installed due to stateless
 address configuration or only list permanent (not dynamic)
--=20
1.8.1.4
