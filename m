From: Syam Sidhardhan <s.syam@samsung.com>
Subject: [PATCH 1/1] openvswitch: Remove unnecessary version.h inclusion
Date: Fri, 09 Jan 2015 20:26:21 +0530
Message-ID: <1420815381-29973-1-git-send-email-s.syam@samsung.com>
Cc: Syam Sidhardhan <s.syam@samsung.com>
To: netdev@vger.kernel.org, syamsidhardh@gmail.com, pshelar@nicira.com,
	davem@davemloft.net, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:20970 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbAIOzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 09:55:02 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NHX00EP603OVUC0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 09 Jan 2015 23:55:00 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

version.h inclusion is not necessary as detected by versioncheck.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 net/openvswitch/vport-geneve.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 347fa23..70e2aae 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -9,8 +9,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/version.h>
-
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/net.h>
-- 
1.7.9.5
