From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/18] batman-adv: update email address for Marek Lindner
Date: Sun, 20 Oct 2013 00:21:56 +0200
Message-ID: <1382221330-3769-5-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:23082 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab3JSWXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:23:01 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 Documentation/ABI/testing/sysfs-class-net-batman-adv |  4 ++--
 Documentation/ABI/testing/sysfs-class-net-mesh       | 12 ++++++------
 Documentation/networking/batman-adv.txt              |  2 +-
 net/batman-adv/main.h                                |  2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-batman-adv b/Documentation/ABI/testing/sysfs-class-net-batman-adv
index bdc0070..7f34a95 100644
--- a/Documentation/ABI/testing/sysfs-class-net-batman-adv
+++ b/Documentation/ABI/testing/sysfs-class-net-batman-adv
@@ -1,13 +1,13 @@
 
 What:           /sys/class/net/<iface>/batman-adv/iface_status
 Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Indicates the status of <iface> as it is seen by batman.
 
 What:           /sys/class/net/<iface>/batman-adv/mesh_iface
 Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 The /sys/class/net/<iface>/batman-adv/mesh_iface file
                 displays the batman mesh interface this <iface>
diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index a86528c..dfdea2b 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -1,7 +1,7 @@
 
 What:           /sys/class/net/<mesh_iface>/mesh/aggregated_ogms
 Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Indicates whether the batman protocol messages of the
                 mesh <mesh_iface> shall be aggregated or not.
@@ -41,21 +41,21 @@ Description:
 
 What:           /sys/class/net/<mesh_iface>/mesh/gw_bandwidth
 Date:           October 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Defines the bandwidth which is propagated by this
                 node if gw_mode was set to 'server'.
 
 What:           /sys/class/net/<mesh_iface>/mesh/gw_mode
 Date:           October 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Defines the state of the gateway features. Can be
                 either 'off', 'client' or 'server'.
 
 What:           /sys/class/net/<mesh_iface>/mesh/gw_sel_class
 Date:           October 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Defines the selection criteria this node will use
                 to choose a gateway if gw_mode was set to 'client'.
@@ -77,14 +77,14 @@ Description:
 
 What:           /sys/class/net/<mesh_iface>/mesh/orig_interval
 Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Defines the interval in milliseconds in which batman
                 sends its protocol messages.
 
 What:           /sys/class/net/<mesh_iface>/mesh/routing_algo
 Date:           Dec 2011
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
+Contact:        Marek Lindner <mareklindner@neomailbox.ch>
 Description:
                 Defines the routing procotol this mesh instance
                 uses to find the optimal paths through the mesh.
diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 89ace66..89490beb 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -199,5 +199,5 @@ Mailing-list:   b.a.t.m.a.n@open-mesh.org (optional  subscription
 
 You can also contact the Authors:
 
-Marek  Lindner  <lindner_marek@yahoo.de>
+Marek  Lindner  <mareklindner@neomailbox.ch>
 Simon  Wunderlich  <sw@simonwunderlich.de>
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index c754f8e..ff55dcc 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -20,7 +20,7 @@
 #ifndef _NET_BATMAN_ADV_MAIN_H_
 #define _NET_BATMAN_ADV_MAIN_H_
 
-#define BATADV_DRIVER_AUTHOR "Marek Lindner <lindner_marek@yahoo.de>, " \
+#define BATADV_DRIVER_AUTHOR "Marek Lindner <mareklindner@neomailbox.ch>, " \
 			     "Simon Wunderlich <sw@simonwunderlich.de>"
 #define BATADV_DRIVER_DESC   "B.A.T.M.A.N. advanced"
 #define BATADV_DRIVER_DEVICE "batman-adv"
-- 
1.8.4
