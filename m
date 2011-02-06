From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Sat, 05 Feb 2011 18:14:24 -0800 (PST)
Message-ID: <20110205.181424.112605200.davem@davemloft.net>
References: <20110202.170750.229739784.davem@davemloft.net>
	<C9A0E70E-D1DB-45CF-ABB1-8CF9A9D03144@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, therbert@google.com
To: alexander.zimmermann@comsys.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752203Ab1BFCNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Feb 2011 21:13:49 -0500
In-Reply-To: <C9A0E70E-D1DB-45CF-ABB1-8CF9A9D03144@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Date: Fri, 04 Feb 2011 09:38:34 +0100

> Could you add a reference to draft?
> 
>> +/* TCP initial congestion window */
>> +#define TCP_INIT_CWND		10
>> +
>> extern struct inet_timewait_death_row tcp_death_row;

Sure, done.

--------------------
tcp: Add reference to initial CWND ietf draft.

Suggested by Alexander Zimmermann

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7118668..adfe6db 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -196,7 +196,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* TCP thin-stream limits */
 #define TCP_THIN_LINEAR_RETRIES 6       /* After 6 linear retries, do exp. backoff */
 
-/* TCP initial congestion window */
+/* TCP initial congestion window as per draft-hkchu-tcpm-initcwnd-01 */
 #define TCP_INIT_CWND		10
 
 extern struct inet_timewait_death_row tcp_death_row;
-- 
1.7.4

