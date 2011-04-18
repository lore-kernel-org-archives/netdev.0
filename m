From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 2/3] sctp: change auth event type name to SCTP_AUTHENTICATION_EVENT
Date: Mon, 18 Apr 2011 11:28:01 +0800
Message-ID: <4DABAFC1.7040105@cn.fujitsu.com>
References: <4DABAEF1.1010506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51041 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751718Ab1DRD2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:28:20 -0400
In-Reply-To: <4DABAEF1.1010506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch change the auth event type name to SCTP_AUTHENTICATION_EVENT,
which is based on API extension compliance.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |    3 ++-
 net/sctp/ulpevent.c     |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 793617e..4525d8c 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -408,7 +408,8 @@ enum sctp_sn_type {
 	SCTP_SHUTDOWN_EVENT,
 	SCTP_PARTIAL_DELIVERY_EVENT,
 	SCTP_ADAPTATION_INDICATION,
-	SCTP_AUTHENTICATION_INDICATION,
+	SCTP_AUTHENTICATION_EVENT,
+#define SCTP_AUTHENTICATION_INDICATION	SCTP_AUTHENTICATION_EVENT
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index dff27d5..62d4a7b 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -843,7 +843,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_authkey(
 	ak = (struct sctp_authkey_event *)
 		skb_put(skb, sizeof(struct sctp_authkey_event));
 
-	ak->auth_type = SCTP_AUTHENTICATION_INDICATION;
+	ak->auth_type = SCTP_AUTHENTICATION_EVENT;
 	ak->auth_flags = 0;
 	ak->auth_length = sizeof(struct sctp_authkey_event);
 
-- 
1.6.5.2


