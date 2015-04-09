From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 1/2] include: update linux/rtnetlink.h
Date: Thu,  9 Apr 2015 10:30:13 +0200
Message-ID: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35316 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015AbbDIIaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 04:30:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/rtnetlink.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 28650a31d77f..702b19b4207e 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -134,6 +134,8 @@ enum {
 
 	RTM_NEWNSID = 88,
 #define RTM_NEWNSID RTM_NEWNSID
+	RTM_DELNSID = 89,
+#define RTM_DELNSID RTM_DELNSID
 	RTM_GETNSID = 90,
 #define RTM_GETNSID RTM_GETNSID
 
@@ -633,6 +635,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_MDB		RTNLGRP_MDB
 	RTNLGRP_MPLS_ROUTE,
 #define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
+	RTNLGRP_NSID,
+#define RTNLGRP_NSID		RTNLGRP_NSID
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
-- 
2.2.2
