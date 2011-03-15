From: Michael Smith <msmith@cbnco.com>
Subject: Re: IPsec tunnel forwarding in net-next-2.6 since 452edd59
Date: Tue, 15 Mar 2011 18:51:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1103151851110.28997@juice.ott.cti.com>
References: <4D7FB054.2090902@cbnco.com> <1300227411.2565.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:36288 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753712Ab1COWvg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 18:51:36 -0400
In-Reply-To: <1300227411.2565.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Mar 2011, Eric Dumazet wrote:

> Could you try following patch ?
> 
> [PATCH] xfrm: fix __xfrm_route_forward()
> 
> This function should return 0 in case of error, 1 if OK
> commit 452edd598f60522 (xfrm: Return dst directly from xfrm_lookup())
> got it wrong.

That does the trick, thanks! Nice catch.

Mike
