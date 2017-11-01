From: Joe Smith <codesoldier1@gmail.com>
Subject: SKB Reference Question
Date: Wed, 1 Nov 2017 10:27:49 -0700
Message-ID: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:48745 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754729AbdKAR1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:27:51 -0400
Received: by mail-lf0-f53.google.com with SMTP id r135so2599617lfe.5
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:27:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How strictly are references on the SKB enforced. For example,
tcp_transmit_skb() clones the SKB and adds a TCP header. Can I assume
that in case of re-transmission the header added will be there and can
be reused instead of creating a new one from scratch. Some fields like
time stamp would need to be updated but they should be unmodified.

Regards,

-- 
JS
