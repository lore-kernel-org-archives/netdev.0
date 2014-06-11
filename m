From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH resend] ip: add nlmon as a device type to help message
Date: Thu, 12 Jun 2014 04:08:38 +0900
Message-ID: <1402513718-19035-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbaFKTIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 15:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though nlmon device can be added, it was not listed
in the output of "ip link help".

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 0d020ef..ce5aa81 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -87,7 +87,7 @@ void iplink_usage(void)
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
-		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti }\n");
+		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon }\n");
 	}
 	exit(-1);
 }
-- 
1.9.0
