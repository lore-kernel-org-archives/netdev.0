From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 10:59:43 +0100
Message-ID: <20130123095943.GA7317@order.stressinduktion.org>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45936 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312Ab3AWJ7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 04:59:44 -0500
Content-Disposition: inline
In-Reply-To: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2013 at 09:01:53PM -0500, Yannick Koehler wrote:
>   I believe that the problem is that once we move the skb into the
> client's receive queue we need to decrease the sk_wmem_alloc variable
> of the server socket since that skb is no more tied to the server.
> The code should then account for this memory as part of the
> sk_rmem_alloc variable on the client's socket.  The function
> "skb_set_owner_r(skb,owner)" would seem to be the function to do that,
> so it would seem to me.

Your analysis does make sense. Could you cook a patch?

Thanks,

  Hannes
