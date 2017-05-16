From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 06/12] ep93xx_eth: add GRO support
Date: Tue, 16 May 2017 13:48:55 -0700
Message-ID: <CANn89iLk=C_MbY9rHC9UufOEyPxrSwVxet61PJZXx1sP3FYLcQ@mail.gmail.com>
References: <20170204232502.22361-1-edumazet@google.com> <20170204232502.22361-7-edumazet@google.com>
 <20170515103132.GA24992@wantstofly.org> <591A12E8.1050603@gmail.com>
 <1494882170.2185.2.camel@Nokia-N900> <8ce1ad39-5f57-ecff-805d-0aaca6fbd138@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ryan Mallon <rmallon@gmail.com>,
        Lennert Buytenhek <buytenh@wantstofly.org>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hartley Sweeten <hsweeten@visionengravers.com>
To: Alexander Sverdlin <alexander.sverdlin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34032 "EHLO
        mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdEPUs4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:48:56 -0400
Received: by mail-yw0-f177.google.com with SMTP id l14so59076154ywk.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:48:56 -0700 (PDT)
In-Reply-To: <8ce1ad39-5f57-ecff-805d-0aaca6fbd138@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 1:41 PM, Alexander Sverdlin
<alexander.sverdlin@gmail.com> wrote:

> it turns out I've used this patch two weeks long already in 4.11; but I've spent
> a couple of hours now torturing the new driver and was not able to provoke
> any inadequate behavior. It either receives all packets in time or not at all.
> If IRQs would be edge-triggered, I'd expect some stale packets, which do not
> arrive at first, but then appear with the packets coming next. This is not
> the case. I've used pktgen module for this, with minimal packets and
> different bursts.
>
> netperf shows 45Mbit/s on UDP_STREAM test, which is also fair amount for
> 200MHz CPU.
>
> So, I see no problems with the change.
>

Thanks a lot for testing !
