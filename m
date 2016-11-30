From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: [PATCH] mlx4: give precise rx/tx bytes/packets
 counters
Date: Wed, 30 Nov 2016 09:35:21 -0800
Message-ID: <1480527321.18162.196.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161130150839.5203ece0@redhat.com>
         <1480521514.18162.191.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35760 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932539AbcK3RgX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:36:23 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so1913499pga.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 09:36:23 -0800 (PST)
In-Reply-To: <CALzJLG8pcuNo4uD3+dVms1gHT9=WfZAM1DDp_J10NgBZ7YZnEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 18:46 +0200, Saeed Mahameed wrote:

> we had/still have the proper stats they are the ones that
> mlx4_en_fold_software_stats is trying to cache into  (they always
> exist),
> but the ones that you are trying to read from (the mlx4 rings) are gone !
> 
> This bug is totally new and as i warned, this is another symptom of
> the real root cause (can't sleep while reading stats).
> 
> Eric what do you suggest ? Keep pre-allocated MAX_RINGS stats  and
> always iterate over all of them to query stats ?
> what if you have one ring/none/1K ? how would you know how many to query ?

I am suggesting I will fix the bug I introduced.

Do not panic.
