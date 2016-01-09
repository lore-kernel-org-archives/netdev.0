From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 12/16] batman-adv: Change ifconfig examples to iproute2
Date: Sat,  9 Jan 2016 21:20:17 +0800
Message-ID: <1452345621-15908-13-git-send-email-a__32540.1354734369$1452346771$gmane$org@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:40111 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754735AbcAINjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:39:17 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 Documentation/networking/batman-adv.txt | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 58e49042fc20..ff23b755f5e4 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -115,14 +115,17 @@ The "bat0" interface can be used like any  other  regular  inter-
 face.  It needs an IP address which can be either statically con-
 figured or dynamically (by using DHCP or similar services):
 
-# NodeA: ifconfig bat0 192.168.0.1
-# NodeB: ifconfig bat0 192.168.0.2
+# NodeA: ip link set up dev bat0
+# NodeA: ip addr add 192.168.0.1/24 dev bat0
+
+# NodeB: ip link set up dev bat0
+# NodeB: ip addr add 192.168.0.2/24 dev bat0
 # NodeB: ping 192.168.0.1
 
 Note:  In  order to avoid problems remove all IP addresses previ-
 ously assigned to interfaces now used by batman advanced, e.g.
 
-# ifconfig eth0 0.0.0.0
+# ip addr flush dev eth0
 
 
 LOGGING/DEBUGGING
-- 
2.7.0
