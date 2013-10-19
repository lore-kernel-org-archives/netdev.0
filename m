From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net v2 1/3] udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
Date: Sat, 19 Oct 2013 22:45:08 +0200
Message-ID: <20131019204508.GE31333@order.stressinduktion.org>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us> <1382178557-14737-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jdmason@kudzu.us, yoshfuji@linux-ipv6.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45410 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3JSUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 16:45:12 -0400
Content-Disposition: inline
In-Reply-To: <1382178557-14737-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 12:29:15PM +0200, Jiri Pirko wrote:
> if up->pending != 0 dontfrag is left with default value -1. That
> causes that application that do:
> sendto len>mtu flag MSG_MORE
> sendto len>mtu flag 0
> will receive EMSGSIZE errno as the result of the second sendto.
> 
> This patch fixes it by respecting IPV6_DONTFRAG socket option.
> 
> introduced by:
> commit 4b340ae20d0e2366792abe70f46629e576adaf5e "IPv6: Complete IPV6_DONTFRAG support"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
