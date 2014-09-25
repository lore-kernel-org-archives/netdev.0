From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 08:53:30 -0700
Message-ID: <CAADnVQJ_FfZEUbFBz4wwZM9Gfbsagfjk51VVbjWJPG7KgJjHWQ@mail.gmail.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:58896 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbaIYPxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:53:31 -0400
Received: by mail-qc0-f180.google.com with SMTP id l6so4752610qcy.25
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:53:30 -0700 (PDT)
In-Reply-To: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 7:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> skb->xmit_more tells us if another skb is coming next.
>
> We need to send doorbell when : xmit_more is not set,
> or txqueue is stopped (preventing next skb to come immediately)
>
> Tested with a modified pktgen version, I got a 40% increase of
> throughput.

this is awesome!

I've been hacking pktgen as well based on Jesper's earlier patch,
but in slightly different way. Sounds like you already have working
pktgen with xmit_more. Do you mind sharing it? even rough patch
would be great.

Thanks
