From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 07/12] ip_tunnel: Add dont fragment flag.
Date: Thu, 13 Jun 2013 11:24:49 -0700
Message-ID: <1371147889-9362-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:34384 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758970Ab3FMSY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:24:57 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so5586507pbb.5
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:24:52 -0700 (PDT)
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
