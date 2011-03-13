From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: documentation update: mailing lists.
Date: Sun, 13 Mar 2011 21:34:22 +0100
Message-ID: <1300048462-4486-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:39120 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753886Ab1CMUeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2011 16:34:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit a6c36ee677607b02d8ecc88e8a12785418b88107 ("bonding: change li=
st
contact to netdev@vger.kernel.org"), the mailing list for bonding
developpement was changed from bonding-devel to netdev.

Update the bonding documentation to reflect this change:

- bonding-devel is used for usage discussions (despite the name).
- netdev is used for developpement discussions.

Also remove the reference to the sourceforge bonding page, which is
deprecated.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 Documentation/networking/bonding.txt |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 25d2f41..b36e741 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -2558,18 +2558,15 @@ enslaved.
 16. Resources and Links
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-The latest version of the bonding driver can be found in the latest
+	The latest version of the bonding driver can be found in the latest
 version of the linux kernel, found on http://kernel.org
=20
-The latest version of this document can be found in either the latest
-kernel source (named Documentation/networking/bonding.txt), or on the
-bonding sourceforge site:
+	The latest version of this document can be found in the latest kernel
+source (named Documentation/networking/bonding.txt).
=20
-http://www.sourceforge.net/projects/bonding
-
-Discussions regarding the bonding driver take place primarily on the
-bonding-devel mailing list, hosted at sourceforge.net.  If you have
-questions or problems, post them to the list.  The list address is:
+	Discussions regarding the usage of the bonding driver take place on t=
he
+bonding-devel mailing list, hosted at sourceforge.net. If you have que=
stions or
+problems, post them to the list.  The list address is:
=20
 bonding-devel@lists.sourceforge.net
=20
@@ -2578,6 +2575,17 @@ be found at:
=20
 https://lists.sourceforge.net/lists/listinfo/bonding-devel
=20
+	Discussions regarding the developpement of the bonding driver take pl=
ace
+on the main Linux network mailing list, hosted at vger.kernel.org. The=
 list
+address is:
+
+netdev@vger.kernel.org
+
+	The administrative interface (to subscribe or unsubscribe) can
+be found at:
+
+http://vger.kernel.org/vger-lists.html#netdev
+
 Donald Becker's Ethernet Drivers and diag programs may be found at :
  - http://web.archive.org/web/*/http://www.scyld.com/network/=20
=20
--=20
1.7.2.3

