From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] iplink: can: fix help text and man page
Date: Thu, 15 May 2014 19:52:19 +0200
Message-ID: <1400176339-2801-1-git-send-email-socketcan@hartkopp.net>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: stephen@networkplumber.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Controller Area Network (CAN) interfaces are physical network interfaces.
They can't be 'created' like software devices by 'ip link add type can'.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 ip/iplink.c           | 4 ++--
 man/man8/ip-link.8.in | 5 +----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 0134d6e..c94261a 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -86,8 +86,8 @@ void iplink_usage(void)
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
-		fprintf(stderr, "          can | bridge | bond | ipoib | ip6tnl | ipip | sit |\n");
-		fprintf(stderr, "          vxlan | gre | gretap | ip6gre | ip6gretap | vti }\n");
+		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
+		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti }\n");
 	}
 	exit(-1);
 }
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 9b555b0..e126046 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -163,9 +163,6 @@ Link types:
 .B bond
 - Bonding device
 .sp
-.B can
-- Controller Area Network interface
-.sp
 .B dummy
 - Dummy network interface
 .sp
@@ -179,7 +176,7 @@ Link types:
 - Virtual interface base on link layer address (MAC)
 .sp
 .B vcan
-- Virtual Local CAN interface
+- Virtual Controller Area Network interface
 .sp
 .B veth
 - Virtual ethernet interface
-- 
2.0.0.rc2

