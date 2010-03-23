From: Jan Kara <jack@suse.cz>
Subject: [PATCH 15/18] net: Provide config option for enabling NAPI tracing
Date: Tue, 23 Mar 2010 01:32:17 +0100
Message-ID: <1269304340-25372-16-git-send-email-jack@suse.cz>
References: <1269304340-25372-1-git-send-email-jack@suse.cz>
Cc: Jan Kara <jack@suse.cz>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269304340-25372-1-git-send-email-jack@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/trace/events/napi.h |    2 ++
 kernel/trace/Kconfig        |    9 +++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index a8989c4..70cb4dd 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -2,6 +2,8 @@
 #define _TRACE_NAPI_H_
 
 #include <linux/netdevice.h>
+#undef TRACE_CONFIG
+#define TRACE_CONFIG CONFIG_NAPI_TRACER
 #include <linux/tracepoint.h>
 
 DECLARE_TRACE(napi_poll,
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index a02d577..88b556c 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -508,6 +508,15 @@ config SKB_TRACER
 
 	  If unsure, say N.
 
+config NAPI_TRACER
+	bool "NAPI tracing"
+	depends on NET
+	select GENERIC_TRACER
+	help
+	  Provide tracing for NAPI functions.
+
+	  If unsure, say N.
+
 config KPROBE_EVENT
 	depends on KPROBES
 	depends on HAVE_REGS_AND_STACK_ACCESS_API
-- 
1.6.4.2
