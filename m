From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 08/11] net: Add NEXTHDR_SCTP to ipv6.h
Date: Tue, 27 Aug 2013 13:20:45 -0700
Message-ID: <1377634848-34327-9-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Joe Stringer <joe@wand.net.nz>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:52825 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753963Ab3H0UVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:16 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so5286573pad.19
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:14 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/net/ipv6.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5fe5649..7bdff04 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -41,6 +41,7 @@
 #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
 #define NEXTHDR_NONE		59	/* No next header */
 #define NEXTHDR_DEST		60	/* Destination options header. */
+#define NEXTHDR_SCTP		132	/* SCTP message. */
 #define NEXTHDR_MOBILITY	135	/* Mobility header. */
 
 #define NEXTHDR_MAX		255
-- 
1.8.1.2
