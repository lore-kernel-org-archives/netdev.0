From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] sctp: add function parameter names to fix compile error
Date: Wed, 15 Aug 2012 13:00:27 +0200
Message-ID: <1345028427-22092-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60885 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab2HOLAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 07:00:33 -0400
Received: by weyx8 with SMTP id x8so909357wey.19
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2012 04:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 13d782f6 introduced this problem.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/sctp/sctp.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index aaa8292..9c6414f 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -367,8 +367,8 @@ void sctp_dbg_objcnt_exit(struct net *);
 #define SCTP_DBG_OBJCNT_INC(name)
 #define SCTP_DBG_OBJCNT_DEC(name)
 
-static inline void sctp_dbg_objcnt_init(struct net *) { return; }
-static inline void sctp_dbg_objcnt_exit(struct net *) { return; }
+static inline void sctp_dbg_objcnt_init(struct net *net) { return; }
+static inline void sctp_dbg_objcnt_exit(struct net *net) { return; }
 
 #endif /* CONFIG_SCTP_DBG_OBJCOUNT */
 
-- 
1.7.10.4
