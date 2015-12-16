From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH iproute2] ipv6: allow setting stable_secret mode
Date: Wed, 16 Dec 2015 12:30:08 +0100
Message-ID: <1450265408-20510-1-git-send-email-hannes@stressinduktion.org>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48423 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932113AbbLPLaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 06:30:16 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 76ABC20714
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 06:30:15 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 ip/iplink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index f30de86d1858a0..e824082f7d8149 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -84,7 +84,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
-	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
+	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret } ]\n");
 	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
 
@@ -176,6 +176,8 @@ static int get_addr_gen_mode(const char *mode)
 		return IN6_ADDR_GEN_MODE_EUI64;
 	if (strcasecmp(mode, "none") == 0)
 		return IN6_ADDR_GEN_MODE_NONE;
+	if (strcasecmp(mode, "stable_secret") == 0)
+		return IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	return -1;
 }
 
-- 
2.5.0
