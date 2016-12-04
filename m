From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Sun, 4 Dec 2016 15:21:15 +0200
Message-ID: <CALzJLG9oRh+hC=riywgRf7fdhMQCZWGdJG_hXHGvDzRiwovyzA@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161130150839.5203ece0@redhat.com> <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
 <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_aT1O1ergGRu8Z0u4nszKYao5RbPfb=1USptwFY1d7PQ@mail.gmail.com>
 <1480539652.18162.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8O28ZBS3sdqLpohPZtpLbLs228K4aO6hYd4URsA3yefA@mail.gmail.com>
 <1480607729.18162.311.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_=Z_anekLaiT0giK+RaOGRWmvK6MUP4UWXqsQQysR55w@mail.gmail.com> <1480612130.18162.321.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33565 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752554AbcLDNV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 08:21:57 -0500
Received: by mail-wm0-f52.google.com with SMTP id c184so12723700wmd.0
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 05:21:36 -0800 (PST)
In-Reply-To: <1480612130.18162.321.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 7:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-12-01 at 18:33 +0200, Saeed Mahameed wrote:
>
>> Thanks for the detailed answer !!
>
> You're welcome.
>
>>
>> BTW you went 5 steps ahead of my original question :)), so far you
>> already have a patch without locking at all (really impressive).
>>
>> What i wanted to ask originally, was regarding the "_bh", i didn't
>> mean to completely remove the "spin_lock_bh",
>> I meant, what happens if we replace "spin_lock_bh"  with "spin_lock",
>> without disabling bh ?
>> I gues raw "sping_lock" handles points (2 to 4) from above, but it
>> won't handle long irqs.
>
> Thats a very good point, the _bh prefix can totally be removed, since
> stats_lock is only acquired from process context.
>
>

That was my initial point, Thanks for the help.
will provide a fix patch later once 4.9 is release.
