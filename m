From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 10/14] ipv6: ICMP6MSGIN_INC_STATS is not used
Date: Wed,  8 Oct 2008 15:51:58 +0400
Message-ID: <1223466722-8169-10-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37712 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879AbYJHLxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:53:18 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4736d8f..01da23c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -148,8 +148,6 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 	_DEVINC(icmpv6msg, , idev, field +256); })
 #define ICMP6MSGOUT_INC_STATS_BH(net, idev, field) ({ (void)(net); \
 	_DEVINC(icmpv6msg, _BH, idev, field +256); })
-#define ICMP6MSGIN_INC_STATS(idev, field) \
-	 _DEVINC(icmpv6msg, , idev, field)
 #define ICMP6MSGIN_INC_STATS_BH(idev, field) \
 	_DEVINC(icmpv6msg, _BH, idev, field)
 
-- 
1.5.3.rc5

