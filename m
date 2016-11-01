From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: enhance tcp collapsing
Date: Tue, 01 Nov 2016 10:39:54 -0700
Message-ID: <1478021994.7065.343.camel@edumazet-glaptop3.roam.corp.google.com>
References: <VI1PR0502MB29577BA8C670D1379CC4F1B7D4A10@VI1PR0502MB2957.eurprd05.prod.outlook.com>
         <1478007189.7065.331.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478014346.7065.342.camel@edumazet-glaptop3.roam.corp.google.com>
         <CADVnQymN18JsVSX-0wT3qSuP9+pB8_8js26SQ_XgRF1jM6raDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36413 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752195AbcKARj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 13:39:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id n85so12192470pfi.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 10:39:55 -0700 (PDT)
In-Reply-To: <CADVnQymN18JsVSX-0wT3qSuP9+pB8_8js26SQ_XgRF1jM6raDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-01 at 12:35 -0400, Neal Cardwell wrote:
> On Tue, Nov 1, 2016 at 11:32 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > From: Eric Dumazet <edumazet@google.com>
> >
> > As Ilya Lesokhin suggested, we can collapse two skbs at retransmit
> > time even if the skb at the right has fragments.
> >
> > We simply have to use more generic skb_copy_bits() instead of
> > skb_copy_from_linear_data() in tcp_collapse_retrans()
> >

> >
> > Reported-by: Ilya Lesokhin <ilyal@mellanox.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > ---
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>
> 

Thanks Neal.

David please hold this patch, further tests show an issue I need to
track and fix.
