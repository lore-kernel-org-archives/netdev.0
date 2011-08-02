From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: document two undocumented options.
Date: Tue,  2 Aug 2011 22:06:55 +0200
Message-ID: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	=?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:38947 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755024Ab1HBUHR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 16:07:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 655f8919d549ad1872e24d826b6ce42530516d2e
    bonding: add min links parameter to 802.3ad

and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
    bonding: add all_slaves_active parameter

introduced new options to bonding, but didn't provide the documentation
for those options.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 Documentation/networking/bonding.txt |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 675612f..058ddea 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -238,6 +238,15 @@ ad_select
=20
 	This option was added in bonding version 3.4.0.
=20
+all_slaves_active
+
+	Specifies that duplicate frames (received on inactive ports) should b=
e
+	dropped (0) or delivered (1).
+
+	Normally, bonding will drop duplicate frames (received on inactive
+	ports), which is desirable for most users. But there are some times
+	it is nice to allow duplicate frames to be delivered.
+
 arp_interval
=20
 	Specifies the ARP link monitoring frequency in milliseconds.
@@ -433,6 +442,18 @@ miimon
 	determined.  See the High Availability section for additional
 	information.  The default value is 0.
=20
+min_links
+
+	Specifies the minimum number of links that must be active before
+	asserting carrier. It is similar to the Cisco EtherChannel min-links
+	feature. This allows setting the minimum number of member ports that
+	must be up (link-up state) before marking the bond device as up
+	(carrier on). This is useful for situations where higher level servic=
es
+	such as clustering want to ensure a minimum number of low bandwidth
+	links are active before switchover.
+
+	This only affect 802.3ad mode.
+
 mode
=20
 	Specifies one of the bonding policies. The default is
--=20
1.7.5.4

