From: David Miller <davem@davemloft.net>
Subject: [PATCH] decnet: Remove unused FIB metric macros.
Date: Sat, 27 Mar 2010 19:26:21 -0700 (PDT)
Message-ID: <20100327.192621.229749704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751319Ab0C1CZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 22:25:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 19D3024C096
	for <netdev@vger.kernel.org>; Sat, 27 Mar 2010 19:26:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Unlike the ipv4 side, these are completely unused.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next-2.6

 include/net/dn_fib.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index 52da6c3..bbcde32 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -50,10 +50,6 @@ struct dn_fib_info {
 	__le16			fib_prefsrc;
 	__u32			fib_priority;
 	__u32			fib_metrics[RTAX_MAX];
-#define dn_fib_mtu  fib_metrics[RTAX_MTU-1]
-#define dn_fib_window fib_metrics[RTAX_WINDOW-1]
-#define dn_fib_rtt fib_metrics[RTAX_RTT-1]
-#define dn_fib_advmss fib_metrics[RTAX_ADVMSS-1]
 	int			fib_nhs;
 	int			fib_power;
 	struct dn_fib_nh	fib_nh[0];
-- 
1.7.0.3

