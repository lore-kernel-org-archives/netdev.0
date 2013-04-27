From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ipv4: remove unused macro.
Date: Sat, 27 Apr 2013 16:39:10 +0300
Message-ID: <1367069950-17137-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:57774 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab3D0Njb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 09:39:31 -0400
Received: by mail-we0-f170.google.com with SMTP id z53so171146wey.1
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 06:39:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the IP_ADD_STATS macro from include/net/ip.h as
it is unused.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 include/net/ip.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index a68f838..a17ca36 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -174,7 +174,6 @@ struct ipv4_config {
 extern struct ipv4_config ipv4_config;
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
 #define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
-#define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
-- 
1.8.1.4
