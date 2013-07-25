From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Fri, 26 Jul 2013 00:11:16 +0200
Message-ID: <20130725221116.GC10216@zirkel.wertarbyte.de>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
 <20130724021420.GA10670@order.stressinduktion.org>
 <20130725162931.GX10216@zirkel.wertarbyte.de>
 <20130725181712.GB24007@order.stressinduktion.org>
 <20130725182818.GZ10216@zirkel.wertarbyte.de>
 <CAKTPYJReVfF85wvpbjCF1XREoh3+wzC1baxibZNE1auexcgigA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:55967 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659Ab3GYWLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 18:11:17 -0400
Content-Disposition: inline
In-Reply-To: <CAKTPYJReVfF85wvpbjCF1XREoh3+wzC1baxibZNE1auexcgigA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Andrew Collins (bsderandrew@gmail.com):

> > I've just completed the patch and sent it to the list, and I also placed the
> > changes in my github account, just in case anyone wants to take a quick peek:
> > https://github.com/wertarbyte/linux/compare/prefixlength
> 
> > +  if (arg->result) { ...
> 
> This NULL check seems unnecessary (fib_table_lookup doesn't check).

I wasn't sure if it was possible for fib_table_lookup to put a NULL pointer there,
so I wanted to make sure following it with ->prefixlen was possible. 

> I like the idea, but I agree with Hannes that it'd be nice to split
> this out into a fib constraint callback.

I'm still not convinced that creating such a callback that will never be called
from outside fib{4,}_rule_action() is worth the effort, but my insight into the code
is still limited; if it's the right thing to do [tm], I won't stand in the way :-)
