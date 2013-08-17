From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec 1/3] ipv6: wire up skb->encapsulation
Date: Sat, 17 Aug 2013 12:02:52 -0700
Message-ID: <1376766172.21329.10.camel@edumazet-glaptop>
References: <20130817175116.GA7001@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	yoshfuji@linux-ipv6.org, nicolas.dichtel@6wind.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:65050 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab3HQTCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 15:02:54 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so3305158pbc.15
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 12:02:53 -0700 (PDT)
In-Reply-To: <20130817175116.GA7001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-17 at 19:51 +0200, Hannes Frederic Sowa wrote:
> When pushing a new header before current one call skb_reset_inner_headers
> to record the position of the inner headers in the various ipv6 tunnel
> protocols.
> 
> We later need this to correctly identify the addresses needed to send
> back an error in the xfrm layer.
> 
> This change is safe, because skb->protocol is always checked before
> dereferencing data from the inner protocol.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@googl.com>
