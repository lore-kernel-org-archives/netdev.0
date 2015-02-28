From: Fan Du <fan.du@intel.com>
Subject: [PATCHv3 net-next 1/4] ipv4: Raise tcp PMTU probe mss base size
Date: Sat, 28 Feb 2015 11:23:02 +0800
Message-ID: <1425093785-27380-2-git-send-email-fan.du@intel.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com>
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31145 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbbB1D1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 22:27:50 -0500
In-Reply-To: <1425093785-27380-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quotes from RFC4821 7.2.  Selecting Initial Values

   It is RECOMMENDED that search_low be initially set to an MTU size
   that is likely to work over a very wide range of environments.  Given
   today's technologies, a value of 1024 bytes is probably safe enough.
   The initial value for search_low SHOULD be configurable.

Moreover, set a small value will introduce extra time for the search
to converge. So set the initial probe base mss size to 1024 Bytes.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 include/net/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8d6b983..7b57e5b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -65,7 +65,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCP_MIN_MSS		88U
 
 /* The least MTU to use for probing */
-#define TCP_BASE_MSS		512
+#define TCP_BASE_MSS		1024
 
 /* After receiving this amount of duplicate ACKs fast retransmit starts. */
 #define TCP_FASTRETRANS_THRESH 3
-- 
1.7.1
