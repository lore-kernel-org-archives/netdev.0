From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: do not export sysctl_tcp_low_latency
Date: Tue, 18 Oct 2016 13:24:07 -0700
Message-ID: <1476822247.5650.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35307 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752735AbcJRUYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 16:24:08 -0400
Received: by mail-pf0-f194.google.com with SMTP id s8so334423pfj.2
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 13:24:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since commit b2fb4f54ecd4 ("tcp: uninline tcp_prequeue()") we no longer
access sysctl_tcp_low_latency from a module.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 79d55eb3ec3f..61b7be303eec 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -86,7 +86,6 @@
 
 int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
-EXPORT_SYMBOL(sysctl_tcp_low_latency);
 
 #ifdef CONFIG_TCP_MD5SIG
 static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
