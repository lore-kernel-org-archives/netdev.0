From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] tun: timer cleanups
Date: Fri, 20 Oct 2017 11:29:54 -0700
Message-ID: <20171020182957.32729-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jason Wang <jasowang@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:53239 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbdJTSaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 14:30:01 -0400
Received: by mail-pf0-f196.google.com with SMTP id e64so12188454pfk.9
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 11:30:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on a syzkaller issue that might have been
fixed already by Cong Wang in commit 0ad646c81b21
("tun: call dev_get_valid_name() before register_netdevice()")
I made three small changes related to flow_gc_timer.

Eric Dumazet (3):
  tun: do not block BH again in tun_flow_cleanup()
  tun: avoid extra timer schedule in tun_flow_cleanup()
  tun: do not arm flow_gc_timer in tun_flow_init()

 drivers/net/tun.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

-- 
2.15.0.rc0.271.g36b669edcc-goog
