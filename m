From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ip-address: Align type list in help and man page
Date: Tue, 28 Jun 2016 15:07:17 +0200
Message-ID: <1467119237-12544-3-git-send-email-phil@nwl.cc>
References: <1467119237-12544-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36468 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752287AbcF1NHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 09:07:36 -0400
In-Reply-To: <1467119237-12544-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds missing entries on both sides until they are identical.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c           | 6 +++---
 man/man8/ip-address.8.in | 3 +++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 56f68eb21c0fc..d4d649505e15a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -95,9 +95,9 @@ static void usage(void)
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 	fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
-	fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
-	fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
-	fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf }\n");
+	fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan | lowpan |\n");
+	fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon | can |\n");
+	fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf | hsr}\n");
 
 	exit(-1);
 }
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 8d34adb336af4..3cbe4181f7e36 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -98,7 +98,9 @@ ip-address \- protocol address management
 .ti -8
 .IR TYPE " := [ "
 .BR bridge " | "
+.BR bridge_slave " |"
 .BR bond " | "
+.BR bond_slave " |"
 .BR can " | "
 .BR dummy " | "
 .BR hsr " | "
@@ -118,6 +120,7 @@ ip-address \- protocol address management
 .BR ip6gre " |"
 .BR ip6gretap " |"
 .BR vti " |"
+.BR vrf " |"
 .BR nlmon " |"
 .BR ipvlan " |"
 .BR lowpan " |"
-- 
2.8.2
