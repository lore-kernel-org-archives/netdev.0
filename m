From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH net v2 0/3] net/packet: fix multiple overflow issues in ring buffers
Date: Wed, 29 Mar 2017 16:11:19 +0200
Message-ID: <cover.1490796500.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36482 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdC2OLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 10:11:36 -0400
Received: by mail-lf0-f48.google.com with SMTP id x137so9472513lff.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 07:11:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset addresses multiple overflows and signedness-related issues
in packet socket ring buffers.

Changes in v2:
- remove cleanup patches, will send in a separate patchset
- use a > UINT_MAX / b to check for a * b overflow

Andrey Konovalov (3):
  net/packet: fix overflow in check for priv area size
  net/packet: fix overflow in check for tp_frame_nr
  net/packet: fix overflow in check for tp_reserve

 net/packet/af_packet.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

-- 
2.12.2.564.g063fe858b8-goog
