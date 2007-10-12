From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 06/12] Remove bogus reference to tc-filters(8) from tc(8) manpage.
Date: Fri, 12 Oct 2007 10:56:41 +0200
Message-ID: <1192179407-22461-6-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
 <1192179407-22461-5-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andreas Barth <aba@not.so.argh.org>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38395 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbXJLI5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:33 -0400
In-Reply-To: <1192179407-22461-5-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Andreas Barth <aba@not.so.argh.org>

Spotted by Ale=C5=A1 Kozumpl=C3=ADk <al_es@seznam.cz>
(http://bugs.debian.org/289225)

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 man/man8/tc.8 |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index b9b8039..6acd572 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -202,8 +202,7 @@ qdiscs will use all three:
 tc filters
 If tc filters are attached to a class, they are consulted first=20
 for relevant instructions. Filters can match on all fields of a packet=
 header,=20
-as well as on the firewall mark applied by ipchains or iptables. See=20
-.BR tc-filters (8).
+as well as on the firewall mark applied by ipchains or iptables.=20
 .TP
 Type of Service
 Some qdiscs have built in rules for classifying packets based on the T=
OS field.
@@ -242,8 +241,7 @@ qdiscs applies.
 .TP=20
 FILTERS
 Filters have a three part ID, which is only needed when using a hashed
-filter hierarchy, for which see
-.BR tc-filters (8).
+filter hierarchy.
 .SH UNITS
 All parameters accept a floating point number, possibly followed by a =
unit.
 .P
--=20
1.5.3.4

