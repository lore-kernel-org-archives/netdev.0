From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] xfrm: remove duplicated include
Date: Sat, 25 Jul 2015 04:44:24 -0400
Message-ID: <1437813864-4368-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2368 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbbGYIoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 04:44:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove dupldated include for <linux/xfrm.h>, since it's already
included by 'xfrm.h'.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/ipxfrm.c       | 1 -
 ip/xfrm_monitor.c | 1 -
 ip/xfrm_policy.c  | 1 -
 ip/xfrm_state.c   | 1 -
 4 files changed, 4 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 9c26428..e583abf 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -34,7 +34,6 @@
 #include <netdb.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
-#include <linux/xfrm.h>
 
 #include "utils.h"
 #include "xfrm.h"
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index ebccb71..8b21efa 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -28,7 +28,6 @@
 #include <stdlib.h>
 #include <string.h>
 #include <netinet/in.h>
-#include <linux/xfrm.h>
 
 #include "utils.h"
 #include "xfrm.h"
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 8f4d1a0..efea1e8 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -29,7 +29,6 @@
 #include <string.h>
 #include <netdb.h>
 #include <linux/netlink.h>
-#include <linux/xfrm.h>
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index d2831d0..b5734da 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -28,7 +28,6 @@
 #include <stdlib.h>
 #include <string.h>
 #include <netdb.h>
-#include <linux/xfrm.h>
 #include "utils.h"
 #include "xfrm.h"
 #include "ip_common.h"
-- 
1.8.3.1
