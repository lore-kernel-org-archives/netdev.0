From: Petr Tesarik <ptesarik@suse.cz>
Subject: [PATCH] remove an unnecessary field in struct tcp_skb_cb
Date: Thu, 13 Nov 2008 11:21:47 +0100
Message-ID: <1226571707.18006.23.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:34413 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752753AbYKMKVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 05:21:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The urg_ptr field is not used anywhere and is merely confusing.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

--
 include/net/tcp.h     |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 438014d..8f26b28 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -590,7 +590,6 @@ struct tcp_skb_cb {
 #define TCPCB_EVER_RETRANS	0x80	/* Ever retransmitted frame	*/
 #define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS)
 
-	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 };
 


