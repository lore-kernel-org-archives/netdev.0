From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vxlan: udp_tunnel duplicate include
 net/udp_tunnel.h
Date: Tue, 9 Feb 2016 22:07:29 -0800
Message-ID: <20160209220729.5f3f3397@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35286 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563AbcBJGHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 01:07:18 -0500
Received: by mail-pf0-f171.google.com with SMTP id c10so6767845pfc.2
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 22:07:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2015-11-03 15:01:17.693751277 -0800
+++ b/drivers/net/vxlan.c	2015-12-14 19:07:35.879811786 -0800
@@ -42,7 +42,7 @@
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
 #include <net/protocol.h>
-#include <net/udp_tunnel.h>
+
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/addrconf.h>
