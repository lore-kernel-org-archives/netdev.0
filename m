From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v6 7/8] net: ns: add
	ieee802154_6lowpan namespace
Date: Fri, 28 Feb 2014 07:32:49 +0100
Message-ID: <1393569170-25722-8-git-send-email-alex.aring@gmail.com>
References: <1393569170-25722-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393569170-25722-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds necessary ieee802154 6lowpan namespace to provide the
inet_frag information. This is a initial support for handling 6lowpan
fragmentation with the inet_frag api.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/net_namespace.h            |  4 ++++
 include/net/netns/ieee802154_6lowpan.h | 13 +++++++++++++
 2 files changed, 17 insertions(+)
 create mode 100644 include/net/netns/ieee802154_6lowpan.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 991dcd9..79387f7 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -15,6 +15,7 @@
 #include <net/netns/packet.h>
 #include <net/netns/ipv4.h>
 #include <net/netns/ipv6.h>
+#include <net/netns/ieee802154_6lowpan.h>
 #include <net/netns/sctp.h>
 #include <net/netns/dccp.h>
 #include <net/netns/netfilter.h>
@@ -90,6 +91,9 @@ struct net {
 #if IS_ENABLED(CONFIG_IPV6)
 	struct netns_ipv6	ipv6;
 #endif
+#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
+	struct netns_ieee802154_lowpan	ieee802154_lowpan;
+#endif
 #if defined(CONFIG_IP_SCTP) || defined(CONFIG_IP_SCTP_MODULE)
 	struct netns_sctp	sctp;
 #endif
diff --git a/include/net/netns/ieee802154_6lowpan.h b/include/net/netns/ieee802154_6lowpan.h
new file mode 100644
index 0000000..88110b7
--- /dev/null
+++ b/include/net/netns/ieee802154_6lowpan.h
@@ -0,0 +1,13 @@
+/*
+ * ieee802154 6lowpan in net namespaces
+ */
+
+#include <net/inet_frag.h>
+
+#ifndef __NETNS_IEEE802154_6LOWPAN_H__
+#define __NETNS_IEEE802154_6LOWPAN_H__
+
+struct netns_ieee802154_lowpan {
+};
+
+#endif
-- 
1.9.0


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
