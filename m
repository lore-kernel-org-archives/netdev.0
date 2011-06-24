From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 13:11:59 -0700
Message-ID: <4E04EF8F.6070900@goop.org>
References: <4E04C961.9010302@goop.org>	<1308938183.2532.8.camel@edumazet-laptop>	<4E04D59B.8060301@goop.org> <20110624.124624.1329947216240823992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:50260 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab1FXUMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 16:12:01 -0400
In-Reply-To: <20110624.124624.1329947216240823992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2011 12:46 PM, David Miller wrote:
> Pages get transferred between different SKBs all the time.
>
> For example, GRO makes extensive use of this technique.
> See net/core/skbuff.c:skb_gro_receive().
>
> It is just one example.

I see, and the new skb doesn't get a destructor copied from the
original, so there'd be no second callback.

Are the pages still attached to the first skb, or are they transferred
completely?

Thanks,
    J


