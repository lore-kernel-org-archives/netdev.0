From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: introduce tcp_try_coalesce
Date: Mon, 23 Apr 2012 22:39:10 -0400
Message-ID: <CADVnQy=igJdbcG4J2HU7nEJUNM84qVcLa08h6g6MQQ8-fvgxHg@mail.gmail.com>
References: <1335201102.5205.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46698 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756259Ab2DXCjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:39:11 -0400
Received: by ghrr11 with SMTP id r11so93197ghr.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 19:39:11 -0700 (PDT)
In-Reply-To: <1335201102.5205.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 23, 2012 at 1:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit c8628155ece3 (tcp: reduce out_of_order memory use) took care of
> coalescing tcp segments provided by legacy devices (linear skbs)
>
> We extend this idea to fragged skbs, as their truesize can be heavy.
>
> ixgbe for example uses 256+1024+PAGE_SIZE/2 = 3328 bytes per segment.
>
> Use this coalescing strategy for receive queue too.
>
> This contributes to reduce number of tcp collapses, at minimal cost, and
> reduces memory overhead and packets drops.

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks for the background info, Eric.

neal
