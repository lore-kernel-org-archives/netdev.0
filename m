From: kaber@trash.net
Subject: [PATCH 22/26] netfilter: ipset: install ipset related header files
Date: Thu,  3 Feb 2011 00:12:00 +0100
Message-ID: <1296688324-7830-23-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44726 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab1BBXMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:35 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild       |    3 +++
 include/linux/netfilter/ipset/Kbuild |    4 ++++
 include/linux/netfilter/xt_set.h     |    1 +
 3 files changed, 8 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/ipset/Kbuild

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 89c0d1e..ba19544 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -1,3 +1,5 @@
+header-y += ipset/
+
 header-y += nf_conntrack_common.h
 header-y += nf_conntrack_ftp.h
 header-y += nf_conntrack_sctp.h
@@ -55,6 +57,7 @@ header-y += xt_quota.h
 header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
+header-y += xt_set.h
 header-y += xt_sctp.h
 header-y += xt_socket.h
 header-y += xt_state.h
diff --git a/include/linux/netfilter/ipset/Kbuild b/include/linux/netfilter/ipset/Kbuild
new file mode 100644
index 0000000..601fe71
--- /dev/null
+++ b/include/linux/netfilter/ipset/Kbuild
@@ -0,0 +1,4 @@
+header-y += ip_set.h
+header-y += ip_set_bitmap.h
+header-y += ip_set_hash.h
+header-y += ip_set_list.h
diff --git a/include/linux/netfilter/xt_set.h b/include/linux/netfilter/xt_set.h
index 69b2bd1..081f1de 100644
--- a/include/linux/netfilter/xt_set.h
+++ b/include/linux/netfilter/xt_set.h
@@ -1,6 +1,7 @@
 #ifndef _XT_SET_H
 #define _XT_SET_H
 
+#include <linux/types.h>
 #include <linux/netfilter/ipset/ip_set.h>
 
 /* Revision 0 interface: backward compatible with netfilter/iptables */
-- 
1.7.2.3

