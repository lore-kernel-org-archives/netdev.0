From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] net: ubuf_info.refcnt conversion
Date: Thu, 31 Aug 2017 13:30:11 -0700
Message-ID: <20170831203013.9219-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:38408 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdHaUaT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 16:30:19 -0400
Received: by mail-pg0-f45.google.com with SMTP id b8so2003058pgn.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 13:30:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yet another atomic_t -> refcount_t conversion, split in two patches.

First patch prepares the automatic conversion done in the second patch.

Eric Dumazet (2):
  net: prepare (struct ubuf_info)->refcnt conversion
  net: convert (struct ubuf_info)->refcnt to refcount_t

 include/linux/skbuff.h | 5 +++--
 net/core/skbuff.c      | 9 +++++----
 net/ipv4/tcp.c         | 2 --
 3 files changed, 8 insertions(+), 8 deletions(-)

-- 
2.14.1.581.gf28d330327-goog
