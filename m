From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Wed, 30 Nov 2016 22:42:35 +0200
Message-ID: <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130150839.5203ece0@redhat.com> <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com> <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:32835 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbcK3Um5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:42:57 -0500
Received: by mail-lf0-f44.google.com with SMTP id c13so155818313lfg.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 12:42:57 -0800 (PST)
In-Reply-To: <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 7:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-11-30 at 18:46 +0200, Saeed Mahameed wrote:
>
>> we had/still have the proper stats they are the ones that
>> mlx4_en_fold_software_stats is trying to cache into  (they always
>> exist),
>> but the ones that you are trying to read from (the mlx4 rings) are gone !
>>
>> This bug is totally new and as i warned, this is another symptom of
>> the real root cause (can't sleep while reading stats).
>>
>> Eric what do you suggest ? Keep pre-allocated MAX_RINGS stats  and
>> always iterate over all of them to query stats ?
>> what if you have one ring/none/1K ? how would you know how many to query ?
>
> I am suggesting I will fix the bug I introduced.
>
> Do not panic.
>
>

Not at all, I trust you are the only one who is capable of providing
the best solution.
I am just trying to read your mind :-).

As i said i like the solution and i want to adapt it to mlx5, so I am
a little bit enthusiastic :)

Thanks.
