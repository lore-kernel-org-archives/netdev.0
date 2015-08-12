From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip-link: fix a typo in help message
Date: Wed, 12 Aug 2015 06:29:59 +0000
Message-ID: <1439360999-6065-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3357 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933441AbbHLG0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 02:26:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a typo: "noarp" -> "arp"

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 7e5c466..fa8aa47 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -507,7 +507,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "off") == 0) {
 				req->i.ifi_flags |= IFF_NOARP;
 			} else
-				return on_off("noarp", *argv);
+				return on_off("arp", *argv);
 		} else if (strcmp(*argv, "vf") == 0) {
 			struct rtattr *vflist;
 			NEXT_ARG();
-- 
1.8.3.1
