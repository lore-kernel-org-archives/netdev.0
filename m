From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: document two undocumented options.
Date: Wed,  3 Aug 2011 22:02:19 +0200
Message-ID: <1312401739-4188-1-git-send-email-nicolas.2p.debian@free.fr>
References: <20110803.034425.1421983987148421662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	shemminger@vyatta.com,
	=?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:54825 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742Ab1HCUCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 16:02:47 -0400
In-Reply-To: <20110803.034425.1421983987148421662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 655f8919d549ad1872e24d826b6ce42530516d2e
    bonding: add min links parameter to 802.3ad

and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
    bonding: add all_slaves_active parameter

introduced new options to bonding, but didn't provide the documentation
for those options.

V2 : add the default value for both options.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 Documentation/networking/bonding.txt |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 675612f..480af6e 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -238,6 +238,18 @@ ad_select
=20
 	This option was added in bonding version 3.4.0.
=20
+all_slaves_active
+
+	Specifies that duplicate frames (received on inactive ports) should b=
e
+	dropped (0) or delivered (1).=20
+
+	Normally, bonding will drop duplicate frames (received on inactive
+	ports), which is desirable for most users. But there are some times
+	it is nice to allow duplicate frames to be delivered.
+
+	The default value is 0 (drop duplicate frames received on inactive
+	ports).
+
 arp_interval
=20
 	Specifies the ARP link monitoring frequency in milliseconds.
@@ -433,6 +445,18 @@ miimon
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
+	links are active before switchover. The default value is 1.
+
+	This option only affect 802.3ad mode.
+
 mode
=20
 	Specifies one of the bonding policies. The default is
--=20
1.7.5.4

