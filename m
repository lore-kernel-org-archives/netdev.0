From: Grant Edwards <grant.b.edwards@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Thu, 7 Jun 2012 14:16:52 +0000 (UTC)
Message-ID: <jqqd4k$i2c$1@dough.gmane.org>
References: <jqo7op$t6f$1@dough.gmane.org>
 <1339008142.26966.40.camel@edumazet-glaptop> <jqo9a6$ah6$1@dough.gmane.org>
 <20120606.120247.1618312724057709285.davem@davemloft.net>
 <jqqa1b$kug$1@dough.gmane.org> <1339077710.5083.12.camel@edumazet-glaptop>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:58845 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760769Ab2FGORJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2012 10:17:09 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ScdWK-0003XG-7O
	for netdev@vger.kernel.org; Thu, 07 Jun 2012 16:17:04 +0200
Received: from dsl.comtrol.com ([64.122.56.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 16:17:04 +0200
Received: from grant.b.edwards by dsl.comtrol.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 16:17:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 07, 2012 at 04:01:50PM +0200, Eric Dumazet wrote:
> On Thu, 2012-06-07 at 13:23 +0000, Grant Edwards wrote:
> > On 2012-06-06, David Miller <davem@davemloft.net> wrote:

> > > It was never a formal API that we would only allocate 'size'
> > > amount of tailroom.
> >
> > How can you say that?

> Documentation was stale, so what ?

So there _was_ a formal API that said you would only allocate 'size'
amount of tailroom.  That's what.

> kmalloc(99) doesnt allocate 99 bytes but 128, so what?

Doing so violated the documented API.

You said there was never any API definition that said tailroom() ==
requested size, and implied that it was stupid to write code that
expected tailroom() == requested size.

I was merely pointing out that the API was indeed documented that way.

> Grant, what about you fix your code ?

I did.

And the API documentation has now been fixed as well, but don't try to
tell me that the API documentation didn't promise to work the way my
code expected it to work.

-- 
Grant Edwards               grant.b.edwards        Yow! Youth of today!
                                  at               Join me in a mass rally
                              gmail.com            for traditional mental
                                                   attitudes!
