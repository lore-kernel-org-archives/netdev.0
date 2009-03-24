From: Josh Stone <jistone@redhat.com>
Subject: [PATCH] Add dependent headers to trace/skb.h
Date: Tue, 24 Mar 2009 12:44:28 -0700
Message-ID: <1237923868-31095-1-git-send-email-jistone@redhat.com>
Cc: Josh Stone <jistone@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52099 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763341AbZCXTod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 15:44:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tracing header needs to include definitions for the macros used and
the types referenced.  This lets automated tracing tools like SystemTap
make use of the tracepoint without any specific knowledge of its
meaning (leaving that to the user).

Signed-off-by: Josh Stone <jistone@redhat.com>
CC: Neil Horman <nhorman@tuxdriver.com>
---
 include/trace/skb.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/trace/skb.h b/include/trace/skb.h
index 3aa8646..a96610f 100644
--- a/include/trace/skb.h
+++ b/include/trace/skb.h
@@ -1,6 +1,9 @@
 #ifndef _TRACE_SKB_H_
 #define _TRACE_SKB_H_
 
+#include <linux/skbuff.h>
+#include <linux/tracepoint.h>
+
 DECLARE_TRACE(kfree_skb,
 	TPPROTO(struct sk_buff *skb, void *location),
 	TPARGS(skb, location));
-- 
1.6.0.6

