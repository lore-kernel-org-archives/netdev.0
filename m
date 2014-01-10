From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] net: gro: change GRO overflow strategy
Date: Thu, 9 Jan 2014 21:28:13 -0500
Message-ID: <CADVnQyma1YgZT8m4in2cD97vNupvhxKVAsZ347-LABnoh6werA@mail.gmail.com>
References: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:56291 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaAJC2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 21:28:14 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so1638745eek.15
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 18:28:13 -0800 (PST)
In-Reply-To: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 5:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
...
> This patch changes strategy to simply evict the oldest flow of
> the list. This works better because of the nature of packet
> trains for which GRO is efficient. This also has the effect
> of lowering the GRO latency if many flows are competing.
...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jerry Chu <hkchu@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
>  net/core/dev.c |   17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

Nice!

neal
