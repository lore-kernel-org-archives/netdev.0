From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [patch iproute2] ipvtap: Adding support for ipvtap device management
Date: Tue, 23 May 2017 16:22:05 -0700
Message-ID: <1495581725-10829-1-git-send-email-sainath.grandhi@intel.com>
Cc: stephen@networkplumber.org,
        Sainath Grandhi <sainath.grandhi@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:41439 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966651AbdEWXYG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 19:24:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for managing ipvtap devices using ip link. ipvtap support
is added to linux with commit 235a9d89da976e2975b3de9afc0bed7b72557983
---
 ip/iplink_ipvlan.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_ipvlan.c b/ip/iplink_ipvlan.c
index f7735f3..153aa2f 100644
--- a/ip/iplink_ipvlan.c
+++ b/ip/iplink_ipvlan.c
@@ -1,4 +1,4 @@
-/* iplink_ipvlan.c	IPVLAN device support
+/* iplink_ipvlan.c	IPVLAN/IPVTAP device support
  *
  *              This program is free software; you can redistribute it and/or
  *              modify it under the terms of the GNU General Public License
@@ -90,3 +90,11 @@ struct link_util ipvlan_link_util = {
 	.print_opt	= ipvlan_print_opt,
 	.print_help	= ipvlan_print_help,
 };
+
+struct link_util ipvtap_link_util = {
+	.id		= "ipvtap",
+	.maxattr	= IFLA_IPVLAN_MAX,
+	.parse_opt	= ipvlan_parse_opt,
+	.print_opt	= ipvlan_print_opt,
+	.print_help	= ipvlan_print_help,
+};
-- 
2.7.4
