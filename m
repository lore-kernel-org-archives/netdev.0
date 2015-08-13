From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip-link: enhance prompt message
Date: Thu, 13 Aug 2015 06:41:50 +0000
Message-ID: <1439448110-3537-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3358 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbbHMGix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 02:38:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance promtp message for 'spoofchk' and 'query_rss' flag, and fix a
typo.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 1836889..520f750 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -329,7 +329,7 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			else if (matches(*argv, "off") == 0)
 				ivs.setting = 0;
 			else
-				invarg("Invalid \"spoofchk\" value\n", *argv);
+				return on_off("spoofchk", *argv);
 			ivs.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_SPOOFCHK, &ivs, sizeof(ivs));
 
@@ -341,7 +341,7 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			else if (matches(*argv, "off") == 0)
 				ivs.setting = 0;
 			else
-				invarg("Invalid \"query_rss\" value\n", *argv);
+				return on_off("query_rss", *argv);
 			ivs.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_RSS_QUERY_EN, &ivs, sizeof(ivs));
 
@@ -1092,7 +1092,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "off") == 0) {
 				flags |= IFF_NOARP;
 			} else
-				return on_off("noarp", *argv);
+				return on_off("arp", *argv);
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
 			mask |= IFF_DYNAMIC;
-- 
1.8.3.1
