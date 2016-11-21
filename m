From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH net 1/1] net: batman-adv: Treat NET_XMIT_CN
 as transmit successfully
Date: Mon, 21 Nov 2016 16:21:52 +0800
Message-ID: <CA+6hz4rZyacN_jg74JLg8EWkno2aJEnwJSTwRaw558uE-zAaxA@mail.gmail.com>
References: <1479688779-1328-1-git-send-email-fgao@ikuai8.com> <1926952.1nDu9mPud9@bentobox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: b.a.t.m.a.n@lists.open-mesh.org, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:35808 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbcKUIVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 03:21:53 -0500
Received: by mail-ua0-f170.google.com with SMTP id 12so220247172uas.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 00:21:53 -0800 (PST)
In-Reply-To: <1926952.1nDu9mPud9@bentobox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sven,

On Mon, Nov 21, 2016 at 4:16 PM, Sven Eckelmann <sven@narfation.org> wrote:
> On Montag, 21. November 2016 08:39:39 CET fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> The tc could return NET_XMIT_CN as one congestion notification, but
>> it does not mean the packe is lost. Other modules like ipvlan,
>
> s/packe/packet/

What's this mean?

>
>> macvlan, and others treat NET_XMIT_CN as success too.
>>
>> So batman-adv should add the NET_XMIT_CN check.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  net/batman-adv/distributed-arp-table.c | 2 +-
>>  net/batman-adv/fragmentation.c         | 2 +-
>>  net/batman-adv/routing.c               | 2 +-
>>  net/batman-adv/tp_meter.c              | 2 +-
>>  4 files changed, 4 insertions(+), 4 deletions(-)
> [...]
>
> Not sure how the batman-adv maintainers see this - but this patch needs
> an additional patch for net-next to also add it to the parts which were
> rewritten.
>
> Kind regards,
>         Sven

Ok. I would commit another patch to net-next.

Best Regards
Feng
