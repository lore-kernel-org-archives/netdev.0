From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] tcp: Out-line tcp_try_rmem_schedule
Date: Thu, 10 May 2012 14:00:56 +0200
Message-ID: <1336651256.12504.151.camel@edumazet-glaptop>
References: <4FABAB39.6090201@parallels.com>
	 <4FABAB7C.6040306@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:59845 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229Ab2EJMBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 08:01:01 -0400
Received: by lbbgm6 with SMTP id gm6so991275lbb.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 05:01:00 -0700 (PDT)
In-Reply-To: <4FABAB7C.6040306@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 15:50 +0400, Pavel Emelyanov wrote:
> As proposed by Eric, make the tcp_input.o thinner.
> 
> add/remove: 1/1 grow/shrink: 1/4 up/down: 868/-1329 (-461)
> function                                     old     new   delta
> tcp_try_rmem_schedule                          -     864    +864
> tcp_ack                                     4811    4815      +4
> tcp_validate_incoming                        817     815      -2
> tcp_collapse                                 860     858      -2
> tcp_send_rcvq                                555     353    -202
> tcp_data_queue                              3435    3033    -402
> tcp_prune_queue                              721       -    -721
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  net/ipv4/tcp_input.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
