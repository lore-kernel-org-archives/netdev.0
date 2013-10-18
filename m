From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Fri, 18 Oct 2013 05:04:40 +0200
Message-ID: <20131018030440.GI18135@order.stressinduktion.org>
References: <525E6B03.1040409@blub.net> <20131016154841.GC18135@order.stressinduktion.org> <525FC1C4.3070605@blub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Valentijn Sessink <valentyn@blub.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42249 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755640Ab3JRDEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 23:04:42 -0400
Content-Disposition: inline
In-Reply-To: <525FC1C4.3070605@blub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 12:53:56PM +0200, Valentijn Sessink wrote:
> Hi,
> 
> Thanks for your fast response, please see below. Sorry for the rather 
> long mail, due to the routing tables. Even though they're really short, 
> the output of ipv6_route is extensive...
> 
> On 16-10-13 17:48, Hannes Frederic Sowa wrote:
> >I do think these two issues are connected. Could you send me a the
> >corresponding ip route output and /proc/net/ipv6_route output for when it
> >works and mtus are correctly handled and when it does not work?
> 
> When it works (please note that the routing cache at first doesn't show 
> an MTU, that only happens after a "too big" has been received, hence the 
> difference before and after a "ps uaxww"), I have the following - this 
> is from last night:

Thanks, I needed this to verify I am on the right track replicating this.
2001:1af8:ff03:3:219:66ff:fe26:6dd is the other end of the connection, I
guess?

Greetings,

  Hannes
