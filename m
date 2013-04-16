From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 9/9] net: sctp: sctp_ulpq: do not use char as a struct member
Date: Tue, 16 Apr 2013 23:07:18 +0200
Message-ID: <1366146438-8815-10-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965376Ab3DPVHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:44 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace char with a more appropriate __u8 bitfield for pd_mode.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/ulpqueue.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index 00e50ba..a2bebd4 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -49,10 +49,10 @@
 
 /* A structure to carry information to the ULP (e.g. Sockets API) */
 struct sctp_ulpq {
-	char pd_mode;
 	struct sctp_association *asoc;
 	struct sk_buff_head reasm;
 	struct sk_buff_head lobby;
+	__u8 pd_mode:1;
 };
 
 /* Prototypes. */
-- 
1.7.11.7
