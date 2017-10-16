From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] tcp: Use pI6c in tcp tracepoint
Date: Mon, 16 Oct 2017 14:24:02 -0700
Message-ID: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Cc: xiyou.wangcong@gmail.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:55782 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752007AbdJPVYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:24:07 -0400
Received: by mail-pg0-f65.google.com with SMTP id b11so7832766pgn.12
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 14:24:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The compact form for IPv6 addresses is more user friendly than the full
version. For example:
   compact: 2001:db8:1::1
      full: 2001:0db8:0001:0000:0000:0000:0000:0004i

Update the tcp tracepoint to show the compact form.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/trace/events/tcp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 3d1cbd072b7e..1ffab6d96e94 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -57,7 +57,7 @@ TRACE_EVENT(tcp_retransmit_skb,
 		}
 	),
 
-	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6 daddrv6=%pI6",
+	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6c daddrv6=%pI6c",
 		  __entry->sport, __entry->dport, __entry->saddr, __entry->daddr,
 		  __entry->saddr_v6, __entry->daddr_v6)
 );
-- 
2.1.4
