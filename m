From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 1/2] tcp: introduce tcp_data_queue_ofo
Date: Sun, 18 Mar 2012 23:49:06 -0400
Message-ID: <CADVnQymyfN8Ezpj28rT2n1Lm2fy07byBt+bU8jEm8+ZULJdg6g@mail.gmail.com>
References: <1332077854.3722.52.camel@edumazet-laptop>
	<CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
	<1332104804.3597.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:62371 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab2CSDtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 23:49:07 -0400
Received: by qadc11 with SMTP id c11so592929qad.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 20:49:06 -0700 (PDT)
In-Reply-To: <1332104804.3597.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 18, 2012 at 5:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Split tcp_data_queue() in two parts for better readability.
>
> tcp_data_queue_ofo() is responsible for queueing incoming skb into out
> of order queue.
>
> Change code layout so that the skb_set_owner_r() is performed only if
> skb is not dropped.
>
> This is a preliminary patch before "reduce out_of_order memory use"
> following patch.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Nice clean-up. Thanks for doing this!

neal
