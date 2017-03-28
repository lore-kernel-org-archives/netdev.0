From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 0/5] net/packet: fix multiple overflow issues in ring buffers
Date: Tue, 28 Mar 2017 16:00:40 +0200
Message-ID: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:32973 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbdC1OBP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:15 -0400
Received: by mail-wr0-f177.google.com with SMTP id w43so92173594wrb.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset addresses multiple overflows and signedness-related issues
in packet socket ring buffers.

Andrey Konovalov (5):
  net/packet: fix overflow in check for priv area size
  net/packet: add explicit checks for tp_frame_size
  net/packet: fix overflow in check for tp_frame_nr
  net/packet: fix overflow in check for tp_reserve
  net/packet: reorder checks for ring buffer parameters

 net/packet/af_packet.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

-- 
2.12.2.564.g063fe858b8-goog
