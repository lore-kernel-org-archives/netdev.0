From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [iproute2] link: add team and team_slave link type
Date: Fri, 25 Nov 2016 22:01:29 +0800
Message-ID: <1480082489-3135-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:19788 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbcKYOCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 09:02:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing team and team_slave link type.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index a8b49c5..1e603e7 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -98,8 +98,8 @@ void iplink_usage(void)
 		fprintf(stderr,
 			"       ip link help [ TYPE ]\n\n"
 			"TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n"
-			"          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n"
-			"          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n"
+			"          bridge | bond | team | ipoib | ip6tnl | ipip | sit | vxlan |\n"
+			"          gre | gretap | ip6gre | ip6gretap | vti | nlmon | team_slave |\n"
 			"          bond_slave | ipvlan | geneve | bridge_slave | vrf | macsec }\n");
 	}
 	exit(-1);
-- 
1.8.3.1
