From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH ipsec v2 1/3] ipv6: wire up skb->encapsulation
Date: Tue, 20 Aug 2013 02:36:51 +0200
Message-ID: <20130820003651.GA3938@order.stressinduktion.org>
References: <20130818114652.GA10192@order.stressinduktion.org> <20130820003546.GA14038@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	yoshfuji@linux-ipv6.org, nicolas.dichtel@6wind.com,
	edumazet@google.com
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33527 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab3HTAgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 20:36:52 -0400
Content-Disposition: inline
In-Reply-To: <20130820003546.GA14038@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 20, 2013 at 10:35:46AM +1000, Simon Horman wrote:
> On Sun, Aug 18, 2013 at 01:46:52PM +0200, Hannes Frederic Sowa wrote:
> > When pushing a new header before current one call skb_reset_inner_headers
> > to record the position of the inner headers in the various ipv6 tunnel
> > protocols.
> > 
> > We later need this to correctly identify the addresses needed to send
> > back an error in the xfrm layer.
> > 
> > This change is safe, because skb->protocol is always checked before
> > dereferencing data from the inner protocol.
> 
> It seems that the intention is to only track the inner-most header
> due to the presence of if (likely(!skb->encapsulation)). Is this the
> intention?

Ack. Do you see problems with this?

Greetings,

  Hannes
