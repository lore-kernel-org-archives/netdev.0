From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/2] net: ubuf_info.refcnt conversion
Date: Thu, 31 Aug 2017 16:48:20 -0700
Message-ID: <20170831234822.26612-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:38592 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751848AbdHaXs1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:48:27 -0400
Received: by mail-pg0-f53.google.com with SMTP id b8so3166390pgn.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:48:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yet another atomic_t -> refcount_t conversion, split in two patches.

First patch prepares the automatic conversion done in the second patch.

Eric Dumazet (2):
  net: prepare (struct ubuf_info)->refcnt conversion
  net: convert (struct ubuf_info)->refcnt to refcount_t

 drivers/vhost/net.c    |  2 +-
 include/linux/skbuff.h |  5 +++--
 net/core/skbuff.c      | 14 ++++----------
 net/ipv4/tcp.c         |  2 --
 4 files changed, 8 insertions(+), 15 deletions(-)

-- 
2.14.1.581.gf28d330327-goog
