From: yegorslists@googlemail.com
Subject: [PATCH] 8021q: update description
Date: Mon, 20 Jan 2014 10:49:39 +0100
Message-ID: <1390211379-3374-1-git-send-email-yegorslists@googlemail.com>
Cc: davem@davemloft.net, Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.vscom.de ([62.145.30.242]:48453 "EHLO mail.visionsystems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380AbaATKMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 05:12:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

Replace deprecated 'vconfig' tool with 'ip' from 'iproute2'. Add
some beautifications like replacing 'ethernet' with 'Ethernet' and
removing unneeded spaces.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 net/8021q/Kconfig |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/8021q/Kconfig b/net/8021q/Kconfig
index b85a91f..4232018 100644
--- a/net/8021q/Kconfig
+++ b/net/8021q/Kconfig
@@ -6,11 +6,11 @@ config VLAN_8021Q
 	tristate "802.1Q/802.1ad VLAN Support"
 	---help---
 	  Select this and you will be able to create 802.1Q VLAN interfaces
-	  on your ethernet interfaces.  802.1Q VLAN supports almost
-	  everything a regular ethernet interface does, including
-	  firewalling, bridging, and of course IP traffic.  You will need
-	  the 'vconfig' tool from the VLAN project in order to effectively
-	  use VLANs.  See the VLAN web page for more information:
+	  on your Ethernet interfaces. 802.1Q VLAN supports almost
+	  everything a regular Ethernet interface does, including
+	  firewalling, bridging, and of course IP traffic. You will need
+	  the 'ip' utility in order to effectively use VLANs.
+	  See the VLAN web page for more information:
 	  <http://www.candelatech.com/~greear/vlan.html>
 
 	  To compile this code as a module, choose M here: the module
-- 
1.7.7
