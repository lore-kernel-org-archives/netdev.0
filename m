From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 10/10] net: flow: Add flow removed notification for eviction
Date: Mon, 29 Dec 2014 11:15:40 +0900
Message-ID: <1419819340-19000-11-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:49188 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbaL2CQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:22 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so16298034pdi.9
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:22 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a flag to flows to allow flow removed notifications
to be sent when eviction occurs.

Inspired by OpenFlow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/uapi/linux/if_flow.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 7264629..9db7b30 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -792,12 +792,14 @@ enum net_flow_rem_reason {
 	NET_FLOW_REM_FLOW_REASON_IDLE_TIMEOUT,	/* Idle timeout */
 	NET_FLOW_REM_FLOW_REASON_HARD_TIMEOUT,	/* Hard timeout */
 	NET_FLOW_REM_FLOW_REASON_DELETE,	/* Deleted (by NET_FLOW_TABLE_CMD_DEL_FLOWS) */
+	NET_FLOW_REM_FLOW_REASON_EVICTION,	/* Evicted by switch */
 };
 
 enum {
 	NET_FLOW_REM_F_IDLE_TIMEOUT	= (1 << NET_FLOW_REM_FLOW_REASON_IDLE_TIMEOUT),
 	NET_FLOW_REM_F_HARD_TIMEOUT	= (1 << NET_FLOW_REM_FLOW_REASON_HARD_TIMEOUT),
 	NET_FLOW_REM_F_DELETE		= (1 << NET_FLOW_REM_FLOW_REASON_DELETE),
+	NET_FLOW_REM_F_EVICTION		= (1 << NET_FLOW_REM_FLOW_REASON_EVICTION),
 };
 
 enum {
-- 
2.1.3
