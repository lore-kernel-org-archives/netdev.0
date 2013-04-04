From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH V3] net: frag queue per hash bucket locking
Date: Thu, 4 Apr 2013 11:58:54 +0200
Message-ID: <20130404095854.GF20292@order.stressinduktion.org>
References: <1365067672.12728.46.camel@localhost> <20130404093816.3613.42475.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50464 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab3DDJ6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 05:58:55 -0400
Content-Disposition: inline
In-Reply-To: <20130404093816.3613.42475.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 11:38:16AM +0200, Jesper Dangaard Brouer wrote:
 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ----
> V2:
> - By analysis from Hannes Frederic Sowa and Eric Dumazet, we don't
>   need the spinlock _bh versions, as Netfilter currently does a
>   local_bh_disable() before entering inet_fragment.
> - Fold-in desc from cover-mail
> V3:
> - Drop the chain_len counter per hash bucket.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
