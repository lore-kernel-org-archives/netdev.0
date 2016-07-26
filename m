From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 2/3] ip {link,address}: add 'macsec' item to TYPE list
Date: Tue, 26 Jul 2016 11:03:19 +0200
Message-ID: <afe4197ccc706761dfed7d3aae313d73f7b8de01.1469520298.git.dcaratti@redhat.com>
References: <cover.1469520298.git.dcaratti@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064AbcGZJEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 05:04:30 -0400
In-Reply-To: <cover.1469520298.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix output of "ip address help" and "ip link help". Update TYPE list in man
pages ip-address.8 and ip-link.8 as well.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 ip/ipaddress.c           | 2 +-
 ip/iplink.c              | 2 +-
 man/man8/ip-address.8.in | 3 ++-
 man/man8/ip-link.8.in    | 3 ++-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 60862c5..ab4b1b1 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -97,7 +97,7 @@ static void usage(void)
 	fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 	fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan | lowpan |\n");
 	fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon | can |\n");
-	fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf | hsr}\n");
+	fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf | hsr | macsec }\n");
 
 	exit(-1);
 }
diff --git a/ip/iplink.c b/ip/iplink.c
index ef17fd9..f9a7e09 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -96,7 +96,7 @@ void iplink_usage(void)
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
-		fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf }\n");
+		fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf | macsec }\n");
 	}
 	exit(-1);
 }
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 7d6eb9b..4338581 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -127,7 +127,8 @@ ip-address \- protocol address management
 .BR nlmon " |"
 .BR ipvlan " |"
 .BR lowpan " |"
-.BR geneve " ]"
+.BR geneve " |"
+.BR macsec " ]"
 
 .SH "DESCRIPTION"
 The
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index c91ef95..ad49c9d 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -184,7 +184,8 @@ ip-link \- network device configuration
 .BR ipvlan " |"
 .BR lowpan " |"
 .BR geneve " |"
-.BR vrf " ]"
+.BR vrf " |"
+.BR macsec " ]"
 
 .ti -8
 .IR ETYPE " := [ " TYPE " |"
-- 
2.5.5
