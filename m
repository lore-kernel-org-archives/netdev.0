From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH 0/2] bring UP loopback device at initialziation
Date: Tue,  4 Jul 2017 12:16:15 -0700
Message-ID: <20170704191615.6412-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biederman <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32847 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdGDTQU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 15:16:20 -0400
Received: by mail-pg0-f66.google.com with SMTP id u62so28433730pgb.0
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 12:16:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

In almost every scenario the loopback device is brought UP after
initialization. So there is no point of bringing up the device in
DOWN state followed by device UP operation. This change exposed
another issue of fib-trie initialization which is corrected in the 
first path.

Mahesh Bandewar (2):
  ipv4: initialize fib_trie prior to register_netdev_notifier call.
  loopback: bringup 'lo' by default at initialization

 drivers/net/loopback.c  | 6 ++++++
 net/ipv4/fib_frontend.c | 4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

-- 
2.13.2.725.g09c95d1e9-goog
