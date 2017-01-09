From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATH net] tcp: do not export tcp_peer_is_proven()
Date: Mon, 09 Jan 2017 08:51:32 -0800
Message-ID: <1483980692.5846.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33900 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967079AbdAIQvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 11:51:35 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so3790832pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 08:51:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 1fb6f159fd21 ("tcp: add tcp_conn_request"),
tcp_peer_is_proven() no longer needs to be exported.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_metrics.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index d46f4d5b1c62edf95791e9d47d966c3bc61e1888..ba8f02d0f283c6eaaf14ed89103adea135093353 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -606,7 +606,6 @@ bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(tcp_peer_is_proven);
 
 void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst)
 {
