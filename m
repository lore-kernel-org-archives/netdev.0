From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 2/2] vlan:remove duplicate <linux/if_vlan.h>
Date: Thu, 28 Jul 2011 16:37:40 +0800
Message-ID: <e25146efacad2adc0c0f765662b8577aadc82ff3.1311841820.git.panweiping3@gmail.com>
References: <cover.1311841820.git.panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:39691 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab1G1Ig1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:36:27 -0400
Received: by qyk29 with SMTP id 29so2611639qyk.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 01:36:27 -0700 (PDT)
In-Reply-To: <cover.1311841820.git.panweiping3@gmail.com>
In-Reply-To: <cover.1311841820.git.panweiping3@gmail.com>
References: <cover.1311841820.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As net/8021q/vlan.h already includes <linux/if_vlan.h>,
so other files that includes vlan.h need not to include it.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/8021q/vlan.c         |    1 -
 net/8021q/vlan_core.c    |    1 -
 net/8021q/vlan_dev.c     |    1 -
 net/8021q/vlan_gvrp.c    |    1 -
 net/8021q/vlan_netlink.c |    1 -
 net/8021q/vlanproc.c     |    1 -
 6 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8970ba1..60030b6 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -36,7 +36,6 @@
 #include <net/netns/generic.h>
 #include <asm/uaccess.h>
 
-#include <linux/if_vlan.h>
 #include "vlan.h"
 #include "vlanproc.h"
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 5f27f8e..66190dc 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -1,6 +1,5 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
-#include <linux/if_vlan.h>
 #include <linux/netpoll.h>
 #include "vlan.h"
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 934e221..1793ffb 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -32,7 +32,6 @@
 
 #include "vlan.h"
 #include "vlanproc.h"
-#include <linux/if_vlan.h>
 
 /*
  *	Rebuild the Ethernet MAC header. This is called after an ARP
diff --git a/net/8021q/vlan_gvrp.c b/net/8021q/vlan_gvrp.c
index 061cece..6153c72 100644
--- a/net/8021q/vlan_gvrp.c
+++ b/net/8021q/vlan_gvrp.c
@@ -8,7 +8,6 @@
  *	version 2 as published by the Free Software Foundation.
  */
 #include <linux/types.h>
-#include <linux/if_vlan.h>
 #include <net/garp.h>
 #include "vlan.h"
 
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index be9a5c1..687ee4f 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -10,7 +10,6 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/if_vlan.h>
 #include <net/net_namespace.h>
 #include <net/netlink.h>
 #include <net/rtnetlink.h>
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index d34b6da..47c99c8 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -27,7 +27,6 @@
 #include <linux/seq_file.h>
 #include <linux/fs.h>
 #include <linux/netdevice.h>
-#include <linux/if_vlan.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include "vlanproc.h"
-- 
1.7.4.4

