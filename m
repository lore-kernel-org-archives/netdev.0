From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net v2 3/3] ip_output: do skb ufo init for peeked non ufo skb as well
Date: Sat, 19 Oct 2013 23:10:19 +0200
Message-ID: <20131019211019.GG31333@order.stressinduktion.org>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us> <1382178557-14737-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jdmason@kudzu.us, yoshfuji@linux-ipv6.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45450 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3JSVKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 17:10:20 -0400
Content-Disposition: inline
In-Reply-To: <1382178557-14737-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 12:29:17PM +0200, Jiri Pirko wrote:
> Now, if user application does:
> sendto len<mtu flag MSG_MORE
> sendto len>mtu flag 0
> The skb is not treated as fragmented one because it is not initialized
> that way. So move the initialization to fix this.
> 
> introduced by:
> commit e89e9cf539a28df7d0eb1d0a545368e9920b34ac "[IPv4/IPv6]: UFO Scatter-gather approach"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks Jiri!
