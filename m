From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/2] zerocopy fixes
Date: Wed,  9 Aug 2017 19:09:42 -0400
Message-ID: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, dsahern@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:37553 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdHIXJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:09:51 -0400
Received: by mail-qk0-f196.google.com with SMTP id x77so7060698qka.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 16:09:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Fix two issues introduced in the msg_zerocopy patchset.

Willem de Bruijn (2):
  sock: fix zerocopy panic in mem accounting
  sock: fix zerocopy_success regression with msg_zerocopy

 include/linux/skbuff.h | 9 +++++++--
 net/core/skbuff.c      | 4 ++--
 2 files changed, 9 insertions(+), 4 deletions(-)

-- 
2.14.0.434.g98096fd7a8-goog
