From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH net-tools] Fix stale references to axattach
Date: Tue, 14 Jul 2015 12:09:43 +0200
Message-ID: <20150714100943.GA13524@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Bernd Eckenfels <bernd@eckenfels.net>, netdev@vger.kernel.org,
	net-tools@lina.inka.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from p54BAE8A5.dip0.t-ipconnect.de ([84.186.232.165]:37430 "EHLO
	h7.dl5rb.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754249AbbGNKSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 06:18:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename all references to axattach to kissattach.

Axattach has been renamed early to kissattach early in the history of
the ax25-utils package which itself has been superseeded by libax25,
ax25-tools and ax25-apps but stale references have remained.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
 TODO                 | 2 +-
 man/de_DE/slattach.8 | 4 ++--
 man/en_US/slattach.8 | 4 ++--
 man/fr_FR/slattach.8 | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/TODO b/TODO
index c8a10dc..798aa19 100644
--- a/TODO
+++ b/TODO
@@ -24,7 +24,7 @@ TODO for net-tools
 [ ] Config file only works with bash not ash.
 [ ] Token ring is almost totally untested.
 [ ] additional tools for IPX, AX.25 etc be bundled [ipxripd004, ipx_* =
tools
-	from caldera, axattach] into existing bins
+	from caldera, kissattach] into existing bins
 [ ] "SIOCAX25OPTRT" [Joerg (DL1BKE)]. 1.3.75
 [ ] dummy NOARP?! (2. default route for preveting hostunreachables on =
linedrop)
 [ ] ppp_dev_stat called for each dev in ifconfig, why? (1.3.17)
diff --git a/man/de_DE/slattach.8 b/man/de_DE/slattach.8
index 603281c..ff6e2f2 100644
--- a/man/de_DE/slattach.8
+++ b/man/de_DE/slattach.8
@@ -76,7 +76,7 @@ ben\(:otigt um eine Leitung zu betreiben.
 F\(:ur
 .B kiss
 Verbindungen sollte stattdessen das
-.B axattach
+.B kissattach
 Programm verwendet werden.
 .TP
 .B "[-s Geschwindigkeit]"
@@ -91,7 +91,7 @@ zu erhalten, f\(:ur andere zu sperren und zu \(:offne=
n.
 .SH FEHLER
 Keine bekannt.
 .SH SIEHE ALSO
-axattach(8), dip(8) pppd(8), sliplogin(8).
+kissattach(8), dip(8) pppd(8), sliplogin(8).
 .SH AUTOREN
 Fred N. van Kempen, <waltje@uwalt.nl.mugnet.org>
 .br
diff --git a/man/en_US/slattach.8 b/man/en_US/slattach.8
index 0e2cfcc..15c12d7 100644
--- a/man/en_US/slattach.8
+++ b/man/en_US/slattach.8
@@ -73,7 +73,7 @@ can be used to put the device back into normal serial=
 operation.
 Using 'ppp' mode is not normally useful as ppp requires an additional =
ppp daemon
 .B pppd
 to be active on the line. For kiss connections the=20
-.B axattach
+.B kissattach
 program should be used.
 .TP
 .B "[\-s speed]"
@@ -87,7 +87,7 @@ indicated terminal port, lock it, and open it.
 .SH BUGS
 None known.
 .SH SEE ALSO
-axattach(8), dip(8) pppd(8), sliplogin(8).
+kissattach(8), dip(8) pppd(8), sliplogin(8).
 .SH AUTHORS
 Fred N. van Kempen, <waltje@uwalt.nl.mugnet.org>
 .br
diff --git a/man/fr_FR/slattach.8 b/man/fr_FR/slattach.8
index d21d0d7..177de18 100644
--- a/man/fr_FR/slattach.8
+++ b/man/fr_FR/slattach.8
@@ -72,7 +72,7 @@ fonctionnement s=E9rie normal. L'utilisation du mode =
'ppp' n'est en
 principe pas utile puisque ppp n=E9cessite le d=E9mon additionnel
 .B pppd
 pour =EAtre actif sur la ligne. Pour les connexions `kiss', le program=
me=20
-.B axattach
+.B kissattach
 doit =EAtre utilis=E9.
 .TP
 .B "[-s vitesse]"
@@ -87,7 +87,7 @@ v=E9rouill=E9 et ouvert.
 .SH BUGS
 Aucun connu.
 .SH VOIR AUSSI
-axattach(8), dip(8) pppd(8), sliplogin(8).
+kissattach(8), dip(8) pppd(8), sliplogin(8).
 .SH AUTEURS
 Fred N. van Kempen, <waltje@uwalt.nl.mugnet.org>
 .br
