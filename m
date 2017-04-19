From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 0/6] net: use skb_cow_head() to deal with cloned skbs
Date: Wed, 19 Apr 2017 09:59:20 -0700
Message-ID: <20170419165926.30631-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:35534 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967431AbdDSQ7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:59:31 -0400
Received: by mail-yb0-f182.google.com with SMTP id 6so7391583ybq.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:59:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Hughes found an issue with smsc95xx driver. Same problematic code
is found in other drivers.

Eric Dumazet (6):
  smsc75xx: use skb_cow_head() to deal with cloned skbs
  cx82310_eth: use skb_cow_head() to deal with cloned skbs
  sr9700: use skb_cow_head() to deal with cloned skbs
  lan78xx: use skb_cow_head() to deal with cloned skbs
  ch9200: use skb_cow_head() to deal with cloned skbs
  kaweth: use skb_cow_head() to deal with cloned skbs

 drivers/net/usb/ch9200.c      |  9 ++-------
 drivers/net/usb/cx82310_eth.c |  7 ++-----
 drivers/net/usb/kaweth.c      | 18 ++++++------------
 drivers/net/usb/lan78xx.c     |  9 ++-------
 drivers/net/usb/smsc75xx.c    |  8 ++------
 drivers/net/usb/sr9700.c      |  9 ++-------
 6 files changed, 16 insertions(+), 44 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
