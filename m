From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: provide correct dst in xfrm_neigh_lookup
Date: Mon, 27 Feb 2017 13:08:02 +0100
Message-ID: <20170227120802.GF694@gauss.secunet.com>
References: <1488038263-12447-1-git-send-email-ja@ssi.bg>
 <20170226.213548.1175046698197997781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ja@ssi.bg>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51310 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751673AbdB0MR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 07:17:29 -0500
Content-Disposition: inline
In-Reply-To: <20170226.213548.1175046698197997781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 26, 2017 at 09:35:48PM -0500, David Miller wrote:
> From: Julian Anastasov <ja@ssi.bg>
> Date: Sat, 25 Feb 2017 17:57:43 +0200
> 
> > Fix xfrm_neigh_lookup to provide dst->path to the
> > neigh_lookup dst_ops method.
> > 
> > When skb is provided, the IP address in packet should already
> > match the dst->path address family. But for the non-skb case,
> > we should consider the last tunnel address as nexthop address.
> > 
> > Fixes: f894cbf847c9 ("net: Add optional SKB arg to dst_ops->neigh_lookup().")
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> This looks good to me.
> 
> Steffen, I applied this directly to my tree, I hope you don't mind.

That's ok, no problem.
