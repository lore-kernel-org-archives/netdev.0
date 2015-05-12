From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: tw_timer_handler() is static
Date: Tue, 12 May 2015 06:22:56 -0700
Message-ID: <1431436976.566.67.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38052 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467AbbELNW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 09:22:58 -0400
Received: by igbhj9 with SMTP id hj9so13648444igb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 06:22:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tw_timer_handler() is only used from net/ipv4/inet_timewait_sock.c

Fixes: 789f558cfb36 ("tcp/dccp: get rid of central timewait timer")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Also cleanly applies to net, I let you decide David ;)

 net/ipv4/inet_timewait_sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 00ec8d5d7e7ee2f1c79dc7446127f13c7e23a331..2ffbd16b79e00279235244c3412046062a86fec5 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -170,7 +170,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
 
-void tw_timer_handler(unsigned long data)
+static void tw_timer_handler(unsigned long data)
 {
 	struct inet_timewait_sock *tw = (struct inet_timewait_sock *)data;
 
