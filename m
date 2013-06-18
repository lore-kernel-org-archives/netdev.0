From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 07/12] ip_tunnel: Add dont fragment flag.
Date: Mon, 17 Jun 2013 17:50:07 -0700
Message-ID: <1371516607-17895-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:36478 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752877Ab3FRAuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 20:50:12 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so3329375pdi.13
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 17:50:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag will be used by ovs tunneling.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 048a97f..791a5b0 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -73,6 +73,7 @@ struct ip_tunnel {
 #define TUNNEL_REC	__cpu_to_be16(0x20)
 #define TUNNEL_VERSION	__cpu_to_be16(0x40)
 #define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
+#define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
 
 struct tnl_ptk_info {
 	__be16 flags;
-- 
1.7.1
