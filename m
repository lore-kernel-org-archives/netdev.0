From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] ip: add nlmon as a device type to help message
Date: Fri,  2 May 2014 11:34:47 +0900
Message-ID: <1398998087-4242-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbaEBCex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 22:34:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though nlmon device can be added, it was not listed
in the output of "ip link help".

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 6a62cc0..8e0c22a 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -87,7 +87,7 @@ void iplink_usage(void)
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          can | bridge | bond | ipoib | ip6tnl | ipip | sit |\n");
-		fprintf(stderr, "          vxlan | gre | gretap | ip6gre | ip6gretap | vti }\n");
+		fprintf(stderr, "          vxlan | gre | gretap | ip6gre | ip6gretap | vti | nlmon }\n");
 	}
 	exit(-1);
 }
-- 
1.9.0
