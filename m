From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/4] bridge: fdb: minor syntax fix in help text
Date: Thu, 29 Oct 2015 10:55:24 +0100
Message-ID: <1446112524-6986-5-git-send-email-phil@nwl.cc>
References: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38185 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946AbbJ2Jz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 05:55:26 -0400
In-Reply-To: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 bridge/fdb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 5ea50ab..4d10925 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -31,11 +31,11 @@ static unsigned int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace ADDR dev DEV\n"
+	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV\n"
 			"              [ self ] [ master ] [ use ] [ router ]\n"
 			"              [ local | temp ] [ dst IPADDR ] [ vlan VID ]\n"
-		        "              [ port PORT] [ vni VNI ] [via DEV]\n");
-	fprintf(stderr, "       bridge fdb {show} [ br BRDEV ] [ brport DEV ]\n");
+		        "              [ port PORT] [ vni VNI ] [ via DEV ]\n");
+	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] ]\n");
 	exit(-1);
 }
 
-- 
2.1.2
