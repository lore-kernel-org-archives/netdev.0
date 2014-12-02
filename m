From: =?us-ascii?B?PT9VVEYtOD9xP1BhdmVsPTIwPUM1PUEwaW1lcmRhPz0=?=
	<psimerda@redhat.com>
Subject: [PATCH iproute2] ip route: don't assume default route
Date: Tue, 2 Dec 2014 17:45:10 +0100
Message-ID: <20141202164510.GA9005@mole.pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:38340 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932252AbaLBQwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 11:52:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just print the help when "ip route del" is called without any other
arguments.

Resolves:

 * https://bugzilla.redhat.com/show_bug.cgi?id=3D997965

Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 ip/iproute.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index d77b1e3..c171f29 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -975,6 +975,9 @@ static int iproute_modify(int cmd, unsigned flags, =
int argc, char **argv)
 		argc--; argv++;
 	}
=20
+	if (!dst_ok)
+		usage();
+
 	if (d || nhs_ok)  {
 		int idx;
=20
--=20
1.8.5.5
