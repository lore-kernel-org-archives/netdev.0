From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec 2/2] ipv6: set skb->protocol on tcp, raw and
 ip6_append_data genereated skbs
Date: Thu, 22 Aug 2013 16:59:37 -0700
Message-ID: <1377215977.4226.138.camel@edumazet-glaptop>
References: <20130822104724.GD26773@secunet.com>
	 <20130822195406.GA4745@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:60257 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab3HVX7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 19:59:40 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so2562899pdj.31
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 16:59:39 -0700 (PDT)
In-Reply-To: <20130822195406.GA4745@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 21:54 +0200, Hannes Frederic Sowa wrote:
> Currently we don't initialize skb->protocol when transmitting data via
> tcp, raw(with and without inclhdr) or udp+ufo or appending data directly
> to the socket transmit queue (via ip6_append_data). This needs to be
> done so that we can get the correct mtu in the xfrm layer.
> 
> Setting of skb->protocol happens only in functions where we also have
> a transmitting socket and a new skb, so we don't overwrite old values.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Seems good to me.

Acked-by: Eric Dumazet <edumazet@google.com>
