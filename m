From: Jan Kara <jack@suse.cz>
Subject: [PATCH 14/18] net: Provide config option for enabling SKB tracing
Date: Tue, 23 Mar 2010 01:32:16 +0100
Message-ID: <1269304340-25372-15-git-send-email-jack@suse.cz>
References: <1269304340-25372-1-git-send-email-jack@suse.cz>
Cc: Jan Kara <jack@suse.cz>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40691 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756030Ab0CWAcQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 20:32:16 -0400
In-Reply-To: <1269304340-25372-1-git-send-email-jack@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/trace/events/skb.h |    2 ++
 kernel/trace/Kconfig       |   10 ++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..cd340df 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -1,5 +1,7 @@
 #undef TRACE_SYSTEM
+#undef TRACE_CONFIG
 #define TRACE_SYSTEM skb
+#define TRACE_CONFIG CONFIG_SKB_TRACER
 
 #if !defined(_TRACE_SKB_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_SKB_H
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index a48ff49..a02d577 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -498,6 +498,16 @@ config JBD2_TRACER
 
 	  If unsure, say N.
 
+config SKB_TRACER
+	bool "SKB tracing"
+	depends on NET
+	select GENERIC_TRACER
+	help
+	  Provide tracing for copying datagrams into iovecs and freeing
+	  skbs.
+
+	  If unsure, say N.
+
 config KPROBE_EVENT
 	depends on KPROBES
 	depends on HAVE_REGS_AND_STACK_ACCESS_API
-- 
1.6.4.2

