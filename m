From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net-next] tcp:typo unset should be unsent
Date: Tue, 18 Jun 2013 21:00:31 +0800
Message-ID: <22f92b3d9538257ffcc47ff9d16d9b146b85d891.1371560363.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab3FRM4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 08:56:54 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5ICusb0023298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 08:56:54 -0400
Received: from localhost.localdomain.com (dhcp-17-97.nay.redhat.com [10.66.17.97])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r5ICuqTd011672
	for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 08:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3dd46ea..e2c1333 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -185,7 +185,7 @@ static inline void tcp_event_ack_sent(struct sock *sk, unsigned int pkts)
 u32 tcp_default_init_rwnd(u32 mss)
 {
 	/* Initial receive window should be twice of TCP_INIT_CWND to
-	 * enable proper sending of new unset data during fast recovery
+	 * enable proper sending of new unsent data during fast recovery
 	 * (RFC 3517, Section 4, NextSeg() rule (2)). Further place a
 	 * limit when mss is larger than 1460.
 	 */
-- 
1.7.4
