From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH iproute2 net-next] bridge: vlan: fix a few "fdb" typos in vlan doc
Date: Tue, 21 Jun 2016 15:28:26 -0400
Message-ID: <20160621192826.9332-1-vivien.didelot@savoirfairelinux.com>
Cc: Stephen Hemminger <shemming@brocade.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37076 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcFUT2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 15:28:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 bridge/vlan.c     | 2 +-
 man/man8/bridge.8 | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 717025a..a8a2e1d 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -299,6 +299,6 @@ int do_vlan(int argc, char **argv)
 	} else
 		return vlan_show(0, NULL);
 
-	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge vlan help\".\n", *argv);
 	exit(-1);
 }
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 08e8a5b..1818542 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -551,8 +551,8 @@ device is the bridge device.
 .BI master
 the vlan is configured on the software bridge (default).
 
-.SS bridge vlan delete - delete a forwarding database entry
-This command removes an existing fdb entry.
+.SS bridge vlan delete - delete a vlan filter entry
+This command removes an existing vlan filter entry.
 
 .PP
 The arguments are the same as with
-- 
2.9.0
