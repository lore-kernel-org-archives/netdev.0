From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 0/2] read vnet_hdr_sz once
Date: Fri,  3 Feb 2017 18:20:47 -0500
Message-ID: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34105 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdBCXUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:20:55 -0500
Received: by mail-qt0-f196.google.com with SMTP id w20so7551601qtb.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:20:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Tuntap devices allow concurrent use and update of field vnet_hdr_sz.
Read the field once to avoid TOCTOU.

Willem de Bruijn (2):
  tun: read vnet_hdr_sz once
  macvtap: read vnet_hdr_size once

 drivers/net/macvtap.c |  4 ++--
 drivers/net/tun.c     | 10 ++++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
