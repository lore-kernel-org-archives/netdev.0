From: Antonio Quartulli <ordex@autistici.org>
Subject: =?UTF-8?q?=5BPATCH=205/9=5D=20batman-adv=3A=20sysfs=20documentation=20should=20keep=20alphabetical=20order?=
Date: Wed, 21 Nov 2012 13:11:55 +0100
Message-ID: <1353499919-28596-6-git-send-email-ordex@autistici.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:50615 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab2KUMNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:13:02 -0500
In-Reply-To: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 .../ABI/testing/sysfs-class-net-batman-adv         | 11 +++---
 Documentation/ABI/testing/sysfs-class-net-mesh     | 44 +++++++++++---=
--------
 2 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-batman-adv b/Doc=
umentation/ABI/testing/sysfs-class-net-batman-adv
index 38dd762..bdc0070 100644
--- a/Documentation/ABI/testing/sysfs-class-net-batman-adv
+++ b/Documentation/ABI/testing/sysfs-class-net-batman-adv
@@ -1,4 +1,10 @@
=20
+What:           /sys/class/net/<iface>/batman-adv/iface_status
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                Indicates the status of <iface> as it is seen by batma=
n.
+
 What:           /sys/class/net/<iface>/batman-adv/mesh_iface
 Date:           May 2010
 Contact:        Marek Lindner <lindner_marek@yahoo.de>
@@ -7,8 +13,3 @@ Description:
                 displays the batman mesh interface this <iface>
                 currently is associated with.
=20
-What:           /sys/class/net/<iface>/batman-adv/iface_status
-Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
-Description:
-                Indicates the status of <iface> as it is seen by batma=
n.
diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documenta=
tion/ABI/testing/sysfs-class-net-mesh
index c81fe89..bc41da6 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -6,6 +6,14 @@ Description:
                 Indicates whether the batman protocol messages of the
                 mesh <mesh_iface> shall be aggregated or not.
=20
+What:           /sys/class/net/<mesh_iface>/mesh/ap_isolation
+Date:           May 2011
+Contact:        Antonio Quartulli <ordex@autistici.org>
+Description:
+                Indicates whether the data traffic going from a
+                wireless client to another wireless client will be
+                silently dropped.
+
 What:           /sys/class/net/<mesh_iface>/mesh/bonding
 Date:           June 2010
 Contact:        Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
@@ -31,14 +39,6 @@ Description:
                 mesh will be fragmented or silently discarded if the
                 packet size exceeds the outgoing interface MTU.
=20
-What:		/sys/class/net/<mesh_iface>/mesh/ap_isolation
-Date:		May 2011
-Contact:	Antonio Quartulli <ordex@autistici.org>
-Description:
-		Indicates whether the data traffic going from a
-		wireless client to another wireless client will be
-		silently dropped.
-
 What:           /sys/class/net/<mesh_iface>/mesh/gw_bandwidth
 Date:           October 2010
 Contact:        Marek Lindner <lindner_marek@yahoo.de>
@@ -60,26 +60,26 @@ Description:
                 Defines the selection criteria this node will use
                 to choose a gateway if gw_mode was set to 'client'.
=20
-What:           /sys/class/net/<mesh_iface>/mesh/orig_interval
-Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
-Description:
-                Defines the interval in milliseconds in which batman
-                sends its protocol messages.
-
 What:           /sys/class/net/<mesh_iface>/mesh/hop_penalty
 Date:           Oct 2010
 Contact:        Linus L=C3=BCssing <linus.luessing@web.de>
 Description:
-		Defines the penalty which will be applied to an
-		originator message's tq-field on every hop.
+                Defines the penalty which will be applied to an
+                originator message's tq-field on every hop.
=20
-What:		/sys/class/net/<mesh_iface>/mesh/routing_algo
-Date:		Dec 2011
-Contact:	Marek Lindner <lindner_marek@yahoo.de>
+What:           /sys/class/net/<mesh_iface>/mesh/orig_interval
+Date:           May 2010
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
 Description:
-		Defines the routing procotol this mesh instance
-		uses to find the optimal paths through the mesh.
+                Defines the interval in milliseconds in which batman
+                sends its protocol messages.
+
+What:           /sys/class/net/<mesh_iface>/mesh/routing_algo
+Date:           Dec 2011
+Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Description:
+                Defines the routing procotol this mesh instance
+                uses to find the optimal paths through the mesh.
=20
 What:           /sys/class/net/<mesh_iface>/mesh/vis_mode
 Date:           May 2010
--=20
1.8.0
