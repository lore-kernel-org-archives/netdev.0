From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] vxlan: remove the useless header file protocol.h
Date: Fri, 26 Aug 2016 22:21:47 +0800
Message-ID: <1472221307-13291-1-git-send-email-zyjzyj2000@gmail.com>
To: netdev@vger.kernel.org, pabeni@redhat.com, daniel@iogearbox.net,
        pshelar@nicira.com, aduyck@mirantis.com,
        hannes@stressinduktion.org, jbenc@redhat.com, davem@davemloft.net,
        zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [114.253.60.16] ([114.253.60.16]:60968 "EHLO mail.rain.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753901AbcHZOWN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 10:22:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

This header file is not used in vxlan.c file.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c0dda6f..3f7e0d2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -27,7 +27,6 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
-#include <net/protocol.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ip6_tunnel.h>
-- 
2.7.4
