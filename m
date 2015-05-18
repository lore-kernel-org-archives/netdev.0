From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH iproute2] bridge: vlan: fix a few "fdb" typos in vlan doc
Date: Mon, 18 May 2015 19:40:09 -0400
Message-ID: <1431992409-3764-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:62518 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034AbbERXko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 19:40:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.savoirfairelinux.com (Postfix) with ESMTP id 00D1862074E
	for <netdev@vger.kernel.org>; Mon, 18 May 2015 19:40:43 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 bridge/vlan.c     | 2 +-
 man/man8/bridge.8 | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 2ae739c..67be952 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -258,6 +258,6 @@ int do_vlan(int argc, char **argv)
 	} else
 		return vlan_show(0, NULL);
 
-	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge vlan help\".\n", *argv);
 	exit(-1);
 }
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 4135d01..a576043 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -494,8 +494,8 @@ device is the bridge device.
 .BI master
 the vlan is configured on the software bridge (default).
 
-.SS bridge vlan delete - delete a forwarding database entry
-This command removes an existing fdb entry.
+.SS bridge vlan delete - delete a vlan filter entry
+This command removes an existing vlan filter entry.
 
 .PP
 The arguments are the same as with
-- 
2.4.0
