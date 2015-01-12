From: Syam Sidhardhan <s.syam@samsung.com>
Subject: [PATCH 1/1 net-next] openvswitch: Remove unnecessary version.h
 inclusion
Date: Mon, 12 Jan 2015 20:49:35 +0530
Message-ID: <1421075975-27483-1-git-send-email-s.syam@samsung.com>
Cc: Syam Sidhardhan <s.syam@samsung.com>
To: netdev@vger.kernel.org, davem@davemloft.net, dev@openvswitch.org,
	pshelar@nicira.com, syamsidhardh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:23152 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbbALPSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 10:18:16 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NI2003ZPL6E1T70@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 13 Jan 2015 00:18:14 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

version.h inclusion is not necessary as detected by versioncheck.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
No code changes. Add net-next prefix flag for net-next tree.

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
