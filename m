From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Thu, 16 Mar 2017 05:00:14 -0700
Message-ID: <1489665614.28631.206.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170314151143.16231-1-edumazet@google.com>
         <20170315040657.GA29637@ast-mbp.thefacebook.com>
         <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170315230608.GA90318@ast-mbp.thefacebook.com>
         <1489626436.28631.198.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170316015618.GA12660@ast-mbp.thefacebook.com>
         <CANn89iJRPmQcShBiPwcK_jaAQZsQOOStg5TmY-=AmORKSNPiOA@mail.gmail.com>
         <20170316053907.GA22917@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34854 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdCPMBd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 08:01:33 -0400
Received: by mail-pf0-f169.google.com with SMTP id x63so18037019pfx.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 05:00:16 -0700 (PDT)
In-Reply-To: <20170316053907.GA22917@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-15 at 22:39 -0700, Alexei Starovoitov wrote:

> when there is no room in the rx fifo the hw will increment the counter.
> That's the same as oom causing alloc fails and rx ring not being replenished.
> When there is nothing free in rx ring to dma the packet to, the hw will
> increment that counter.

After 4096 frames were lost buy linux mlx4 driver, then hw will finally
catch up and start increasing its own hw counter.


While you pretended that you received millions of frames and wanted that
not a single one could be dropped without a report.

This is simply not true.

I do not believe I will continue the discussion.

We can not really agree it seems, so why annoying all netdev readers.
