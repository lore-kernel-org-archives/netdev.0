From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast
 address
Date: Mon, 17 Feb 2014 10:32:31 +0100
Message-ID: <20140217093231.GA4609@cpaasch-mac>
References: <1392212332-10463-1-git-send-email-fx.lebail@yahoo.com>
 <20140213001624.GJ11150@order.stressinduktion.org>
 <20140217.001545.981758741332832466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, fx.lebail@yahoo.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:60818 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaBQJch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 04:32:37 -0500
Content-Disposition: inline
In-Reply-To: <20140217.001545.981758741332832466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/14 - 00:15:45, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 13 Feb 2014 01:16:24 +0100
> 
> > [added Cc list from old thread]
> > 
> > On Wed, Feb 12, 2014 at 02:38:51PM +0100, Francois-Xavier Le Bail wrote:
> >> - Use ipv6_chk_acast_addr_src() in inet6_bind().
> >> 
> >> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> > 
> > I would agree with the change but would like to see some people from the old
> > thread about this change to agree with it, too.
> 
> I hear crickets... instead of other reviews :-)

I don't have strong opinions for or against this patch.

I was only involved in the original thread because F-X claimed that
draft-iab-anycast-arch-implications (now RFC 7094) allows the use of anycast
addresses for TCP, which is not what RFC 7094 is saying. There is no
recommendation concerning TCP in the RFC and the situation is rather unclear.


Cheers,
Christoph
