From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/7] Add the netns_ipv4 struct
Date: Tue, 11 Dec 2007 20:45:58 +0300
Message-ID: <475ECCD6.4080205@openvz.org>
References: <475ECC69.1040809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39008 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767AbXLKRqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 12:46:10 -0500
In-Reply-To: <475ECC69.1040809@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv4 will store its parameters inside this structure.
This one is empty now, but it will be eventually filled.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 18da0af..d04ddf2 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -10,6 +10,7 @@
 
 #include <net/netns/unix.h>
 #include <net/netns/packet.h>
+#include <net/netns/ipv4.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -46,6 +47,7 @@ struct net {
 
 	struct netns_packet	packet;
 	struct netns_unix	unx;
+	struct netns_ipv4	ipv4;
 };
 
 #ifdef CONFIG_NET
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
new file mode 100644
index 0000000..ce830d5
--- /dev/null
+++ b/include/net/netns/ipv4.h
@@ -0,0 +1,9 @@
+/*
+ * ipv4 in net namespaces
+ */
+
+#ifndef __NETNS_IPV4_H__
+#define __NETNS_IPV4_H__
+struct netns_ipv4 {
+};
+#endif
-- 
1.5.3.4

