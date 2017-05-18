From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next] tcp: fix tcp_rearm_rto()
Date: Thu, 18 May 2017 12:55:49 -0400
Message-ID: <CACSApvZ6ohkO7tvU65SCFHy2FWoMppKaPST-3nWMimSruQO16w@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-16-edumazet@google.com>
 <1495110825.6465.22.camel@edumazet-glaptop3.roam.corp.google.com> <1495124158.6465.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35442 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932635AbdERQ4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 12:56:31 -0400
Received: by mail-io0-f171.google.com with SMTP id f102so32235981ioi.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 09:56:31 -0700 (PDT)
In-Reply-To: <1495124158.6465.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 12:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> skbs in (re)transmit queue no longer have a copy of jiffies
> at the time of the transmit : skb->skb_mstamp is now in usec unit,
> with no correlation to tcp_jiffies32.
>
> We have to convert rto from jiffies to usec, compute a time difference
> in usec, then convert the delta to HZ units.
>
> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Thank you for the quick fix, Eric!
