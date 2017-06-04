From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH iproute2 V2] iplink: Update usage in help message
Date: Sun,  4 Jun 2017 15:36:48 +0300
Message-ID: <1496579808-31933-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58070 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751157AbdFDMg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 08:36:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Add to usage message a description of how to configure Infiniband node
and port GUIDs. Also modify the man page to emphasize the GUIDs are
configured for Infiniband VFs.

Fixes: d91fb3f4c7e4 ("Add support for configuring Infiniband GUIDs")
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
v2:
* Modified man page as well.

 ip/iplink.c           | 2 ++
 man/man8/ip-link.8.in | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index da3f9a779351..ea112f71befc 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -91,6 +91,8 @@ void iplink_usage(void)
 		"				   [ query_rss { on | off} ]\n"
 		"				   [ state { auto | enable | disable} ] ]\n"
 		"				   [ trust { on | off} ] ]\n"
+		"				   [ node_guid { eui64 } ]\n"
+		"				   [ port_guid { eui64 } ]\n"
 		"			  [ xdp { off |\n"
 		"				  object FILE [ section NAME ] [ verbose ] |\n"
 		"				  pinned FILE } ]\n"
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index a5ddfe7a106e..48417dbce80a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1564,10 +1564,10 @@ sent by the VF.
 which may impact security and/or performance. (e.g. VF multicast promiscuous mode)
 .sp
 .BI node_guid " eui64"
-- configure node GUID for the VF.
+- configure node GUID for Infiniband VFs.
 .sp
 .BI port_guid " eui64"
-- configure port GUID for the VF.
+- configure port GUID for Infiniband VFs.
 .in -8
 
 .TP
-- 
1.8.3.1
