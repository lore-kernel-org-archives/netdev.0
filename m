From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 1/6] net: sctp: remove TEST_FRAME ifdef
Date: Tue, 25 Jun 2013 18:17:25 +0200
Message-ID: <1372177050-17829-2-git-send-email-dborkman@redhat.com>
References: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408Ab3FYQRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 12:17:38 -0400
In-Reply-To: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do neither ship a test_frame.h, nor will this be compatible with
the 2.5 out-of-tree lksctp kernel test suite anyway. So remove this
artefact.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/sctp.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 6321c08..15214a8 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -188,11 +188,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  *  Section:  Macros, externs, and inlines
  */
 
-
-#ifdef TEST_FRAME
-#include <test_frame.h>
-#else
-
 /* spin lock wrappers. */
 #define sctp_spin_lock_irqsave(lock, flags) spin_lock_irqsave(lock, flags)
 #define sctp_spin_unlock_irqrestore(lock, flags)  \
@@ -218,8 +213,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
 #define SCTP_INC_STATS_USER(net, field) SNMP_INC_STATS_USER((net)->sctp.sctp_statistics, field)
 #define SCTP_DEC_STATS(net, field)      SNMP_DEC_STATS((net)->sctp.sctp_statistics, field)
 
-#endif /* !TEST_FRAME */
-
 /* sctp mib definitions */
 enum {
 	SCTP_MIB_NUM = 0,
-- 
1.7.11.7
