From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] bridge: vlan: remove wrong stats help
Date: Wed, 12 Oct 2016 15:02:28 +0200
Message-ID: <1476277348-32302-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35639 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755330AbcJLNCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 09:02:47 -0400
Received: by mail-qk0-f173.google.com with SMTP id z190so29941365qkc.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:02:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I did the per-vlan stats iproute2 support, I left out a hunk from a
previous version of the patch that was using a special subcommand "stats".
Since the latest version uses the -s switch remove the help for the stats
subcommand.

Fixes: 7abf5de677e32 ("bridge: vlan: add support to display per-vlan statistics")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
The commit is only in iproute2 net-next branch.

 bridge/vlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 0b6c69077160..ebcdacee309b 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -24,7 +24,6 @@ static void usage(void)
 	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid ] [ untagged ]\n");
 	fprintf(stderr, "                                                     [ self ] [ master ]\n");
 	fprintf(stderr, "       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n");
-	fprintf(stderr, "       bridge vlan { stats } [ dev DEV ] [ vid VLAN_ID ]\n");
 	exit(-1);
 }
 
-- 
2.1.4
