From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/3] [SCTP]: Fix the name of the authentication event.
Date: Fri,  4 Jan 2008 14:45:44 -0500
Message-ID: <1199475946-11103-2-git-send-email-vladislav.yasevich@hp.com>
References: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:19329 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbYADToa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 14:44:30 -0500
In-Reply-To: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The even should be called SCTP_AUTHENTICATION_INDICATION.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |    2 +-
 net/sctp/ulpevent.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 00848b6..954090b 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -450,7 +450,7 @@ enum sctp_sn_type {
 	SCTP_SHUTDOWN_EVENT,
 	SCTP_PARTIAL_DELIVERY_EVENT,
 	SCTP_ADAPTATION_INDICATION,
-	SCTP_AUTHENTICATION_EVENT,
+	SCTP_AUTHENTICATION_INDICATION,
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 2c17c7e..3073143 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -830,7 +830,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_authkey(
 	ak = (struct sctp_authkey_event *)
 		skb_put(skb, sizeof(struct sctp_authkey_event));
 
-	ak->auth_type = SCTP_AUTHENTICATION_EVENT;
+	ak->auth_type = SCTP_AUTHENTICATION_INDICATION;
 	ak->auth_flags = 0;
 	ak->auth_length = sizeof(struct sctp_authkey_event);
 
-- 
1.5.3.5

