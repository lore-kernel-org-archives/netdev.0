From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec 3/3] xfrm: choose protocol family by skb protocol
Date: Sat, 17 Aug 2013 12:04:46 -0700
Message-ID: <1376766286.21329.12.camel@edumazet-glaptop>
References: <20130817175137.GA7088@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:41637 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab3HQTEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 15:04:47 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so3280747pbc.39
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 12:04:46 -0700 (PDT)
In-Reply-To: <20130817175137.GA7088@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-17 at 19:51 +0200, Hannes Frederic Sowa wrote:
> We need to choose the protocol family by skb->protocol. Otherwise we
> call the wrong xfrm{4,6}_local_error handler in case an ipv6 sockets is
> used in ipv4 mode, in which case we should call down to xfrm4_local_error
> (ip6 sockets are a superset of ip4 ones).
> 
> We are called before before ip_output functions, so skb->protocol is
> not reset.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
