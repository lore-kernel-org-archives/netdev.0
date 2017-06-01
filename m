From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH iproute2] iplink: Update usage in help message
Date: Thu,  1 Jun 2017 11:00:42 +0300
Message-ID: <1496304042-8773-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39745 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750848AbdFAIBD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 04:01:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Add to usage message a description of how to configure Infiniband node
and port GUIDs.

Fixes: d91fb3f4c7e4 ('Add support for configuring Infiniband GUIDs')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 ip/iplink.c | 2 ++
 1 file changed, 2 insertions(+)

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
-- 
1.8.3.1
