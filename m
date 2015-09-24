From: Karl Heiss <kheiss@gmail.com>
Subject: [PATCH net 1/2] sctp: Whitespace fix
Date: Thu, 24 Sep 2015 12:15:06 -0400
Message-ID: <1443111307-16503-2-git-send-email-kheiss@gmail.com>
References: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34889 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417AbbIXQPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 12:15:12 -0400
In-Reply-To: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix indentation in sctp_generate_heartbeat_event.

Signed-off-by: Karl Heiss <kheiss@gmail.com>
---
 net/sctp/sm_sideeffect.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 35df126..f554b9a 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -388,8 +388,8 @@ void sctp_generate_heartbeat_event(unsigned long data)
 			   asoc->state, asoc->ep, asoc,
 			   transport, GFP_ATOMIC);
 
-	 if (error)
-		 asoc->base.sk->sk_err = -error;
+	if (error)
+		asoc->base.sk->sk_err = -error;
 
 out_unlock:
 	bh_unlock_sock(asoc->base.sk);
-- 
1.7.1
