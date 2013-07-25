From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Thu, 25 Jul 2013 20:17:12 +0200
Message-ID: <20130725181712.GB24007@order.stressinduktion.org>
References: <20130723220221.GP10216@zirkel.wertarbyte.de> <20130724021420.GA10670@order.stressinduktion.org> <20130725162931.GX10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:39668 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab3GYSRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:17:13 -0400
Content-Disposition: inline
In-Reply-To: <20130725162931.GX10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 06:29:32PM +0200, Stefan Tomanek wrote:
> Dies schrieb Hannes Frederic Sowa (hannes@stressinduktion.org):
> 
> > I would try to factor the prefixlen_min check out into a
> > e.g. fib4_rule_constrain function for which a new field in fib_rules_ops
> > needs to be created as callback. Also it would be nice to have IPv6
> > support, too. ;)
> 
> I was working on my patchset again and considered your suggestion; however I'm
> not sure whether factoring out the constraints into a separate function is
> actually that useful, since they are only called from one specific location for
> each protocol; can you think of another useful application?

I don't have a strong opinion on that but I do find that it does better fit into
the design of fib_rules and will be easier to extend in future IMHO.

> I however did like the idea of adding IPv6 support, so I did -
> I'll post the new patch later on.

Cool, thanks.

Greetings,

  Hannes
