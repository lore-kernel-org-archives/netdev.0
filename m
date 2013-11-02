From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 03/11] openvswitch: remove duplicated include from vport-gre.c
Date: Sat,  2 Nov 2013 00:43:42 -0700
Message-ID: <1383378230-59624-4-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:42530 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754484Ab3KBVw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 17:52:27 -0400
Received: by mail-pb0-f48.google.com with SMTP id mc17so5630047pbc.35
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 14:52:26 -0700 (PDT)
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-gre.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index c99dea5..a3d6951 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -24,8 +24,6 @@
 #include <linux/if_tunnel.h>
 #include <linux/if_vlan.h>
 #include <linux/in.h>
-#include <linux/if_vlan.h>
-#include <linux/in.h>
 #include <linux/in_route.h>
 #include <linux/inetdevice.h>
 #include <linux/jhash.h>
-- 
1.8.3.2
