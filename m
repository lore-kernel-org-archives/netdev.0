From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SKB Reference Question
Date: Wed, 01 Nov 2017 10:33:31 -0700
Message-ID: <1509557611.3828.45.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joe Smith <codesoldier1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:55526 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKARde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:33:34 -0400
Received: by mail-io0-f175.google.com with SMTP id p186so7697021ioe.12
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:33:33 -0700 (PDT)
In-Reply-To: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-11-01 at 10:27 -0700, Joe Smith wrote:
> How strictly are references on the SKB enforced. For example,
> tcp_transmit_skb() clones the SKB and adds a TCP header. Can I assume
> that in case of re-transmission the header added will be there and can
> be reused instead of creating a new one from scratch. Some fields like
> time stamp would need to be updated but they should be unmodified.


Not sure what you are trying to do, but this seems messy ;)

At rtx time, there is no guarantee that the master skb has not been
changed, so the content of TCP header might be wrong anyway.
