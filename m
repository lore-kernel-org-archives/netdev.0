From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip-link: remove unnecessary return
Date: Thu, 13 Aug 2015 07:48:15 +0000
Message-ID: <1439452095-5253-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9317 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbbHMHqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 03:46:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary retrun, because invarg() exit.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iplink_bridge.c | 30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index e704e29..61e4cda 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -42,47 +42,41 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 	while (argc > 0) {
 		if (matches(*argv, "forward_delay") == 0) {
 			NEXT_ARG();
-			if (get_u32(&val, *argv, 0)) {
+			if (get_u32(&val, *argv, 0))
 				invarg("invalid forward_delay", *argv);
-				return -1;
-			}
+
 			addattr32(n, 1024, IFLA_BR_FORWARD_DELAY, val);
 		} else if (matches(*argv, "hello_time") == 0) {
 			NEXT_ARG();
-			if (get_u32(&val, *argv, 0)) {
+			if (get_u32(&val, *argv, 0))
 				invarg("invalid hello_time", *argv);
-				return -1;
-			}
+
 			addattr32(n, 1024, IFLA_BR_HELLO_TIME, val);
 		} else if (matches(*argv, "max_age") == 0) {
 			NEXT_ARG();
-			if (get_u32(&val, *argv, 0)) {
+			if (get_u32(&val, *argv, 0))
 				invarg("invalid max_age", *argv);
-				return -1;
-			}
+
 			addattr32(n, 1024, IFLA_BR_MAX_AGE, val);
 		} else if (matches(*argv, "ageing_time") == 0) {
 			NEXT_ARG();
-			if (get_u32(&val, *argv, 0)) {
+			if (get_u32(&val, *argv, 0))
 				invarg("invalid ageing_time", *argv);
-				return -1;
-			}
+
 			addattr32(n, 1024, IFLA_BR_AGEING_TIME, val);
 		} else if (matches(*argv, "stp_state") == 0) {
 			NEXT_ARG();
-			if (get_u32(&val, *argv, 0)) {
+			if (get_u32(&val, *argv, 0))
 				invarg("invalid stp_state", *argv);
-				return -1;
-			}
+
 			addattr32(n, 1024, IFLA_BR_STP_STATE, val);
 		} else if (matches(*argv, "priority") == 0) {
 			__u16 prio;
 
 			NEXT_ARG();
-			if (get_u16(&prio, *argv, 0)) {
+			if (get_u16(&prio, *argv, 0))
 				invarg("invalid priority", *argv);
-				return -1;
-			}
+
 			addattr16(n, 1024, IFLA_BR_PRIORITY, prio);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
-- 
1.8.3.1
