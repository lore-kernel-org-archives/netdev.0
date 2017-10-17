From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] ip: bridge_slave: add neigh_suppress to the type help and man pages
Date: Tue, 17 Oct 2017 16:11:26 +0300
Message-ID: <1508245886-24603-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:47385 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932145AbdJQNLe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 09:11:34 -0400
Received: by mail-wm0-f50.google.com with SMTP id t69so3809822wmt.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 06:11:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add neigh_suppress to the type help and document it in ip-link's man page.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge_slave.c | 1 +
 man/man8/ip-link.8.in    | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 25eccf0cb4f9..0d5a01145d9e 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -38,6 +38,7 @@ static void print_explain(FILE *f)
 		"                        [ mcast_fast_leave {on | off} ]\n"
 		"                        [ mcast_flood {on | off} ]\n"
 		"                        [ group_fwd_mask MASK ]\n"
+		"                        [ neigh_suppress {on | off} ]\n"
 	);
 }
 
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index f0f350eb1998..153665cac679 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1747,7 +1747,9 @@ the following additional arguments are supported:
 ] [
 .BR mcast_flood " { " on " | " off " }"
 ] [
-.BR group_fwd_mask " MASK ]"
+.BR group_fwd_mask " MASK"
+] [
+.BR neigh_suppress " { " on " | " off " } ]"
 
 .in +8
 .sp
@@ -1825,6 +1827,9 @@ option above.
 .BI group_fwd_mask " MASK "
 - set the group forward mask. This is the bitmask that is applied to decide whether to forward incoming frames destined to link-local addresses, ie addresses of the form 01:80:C2:00:00:0X (defaults to 0, ie the bridge does not forward any link-local frames coming on this port).
 
+.BR neigh_suppress " { " on " | " off " }"
+- controls whether neigh discovery (arp and nd) proxy and suppression is enabled on the port. By default this flag is off.
+
 .in -8
 
 .TP
-- 
2.1.4
