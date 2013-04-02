From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: Remove dead sysctl_tcp_cookie_size declaration
Date: Tue,  2 Apr 2013 13:13:07 -0400
Message-ID: <1364922787-3756-1-git-send-email-ncardwell@google.com>
Cc: edumazet@google.com, ycheng@google.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:55456 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761710Ab3DBRNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 13:13:11 -0400
Received: by mail-oa0-f74.google.com with SMTP id k14so148507oag.3
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 10:13:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a declaration left over from the TCPCT-ectomy. This sysctl is
no longer referenced anywhere since 1a2c6181c4 ("tcp: Remove TCPCT").

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d1dcb59..4475aaf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -282,7 +282,6 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
-extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
-- 
1.8.1.3
