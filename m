From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 03/20] iplink: fix help text syntax
Date: Wed, 24 Feb 2016 09:21:16 +0100
Message-ID: <1456302093-697-4-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46663 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757932AbcBXIVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:21:45 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of extraneous closing brackets and while here, merge the double
netns parameter.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 5ab9d613c4f99..5a220276f1f96 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -70,17 +70,16 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ address LLADDR ]\n");
 	fprintf(stderr, "	                  [ broadcast LLADDR ]\n");
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
-	fprintf(stderr, "	                  [ netns PID ]\n");
-	fprintf(stderr, "	                  [ netns NAME ]\n");
+	fprintf(stderr, "	                  [ netns { PID | NAME } ]\n");
 	fprintf(stderr, "	                  [ link-netnsid ID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 
-	fprintf(stderr, "				   [ rate TXRATE ] ]\n");
+	fprintf(stderr, "				   [ rate TXRATE ]\n");
 
-	fprintf(stderr, "				   [ spoofchk { on | off} ] ]\n");
-	fprintf(stderr, "				   [ query_rss { on | off} ] ]\n");
+	fprintf(stderr, "				   [ spoofchk { on | off} ]\n");
+	fprintf(stderr, "				   [ query_rss { on | off} ]\n");
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
-- 
2.6.4
