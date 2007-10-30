From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Oops in 2.6.21-rc4, 2.6.23
Date: Tue, 30 Oct 2007 15:11:20 +0100
Message-ID: <20071030141120.GA3997@ff.dom.local>
References: <20071015173956.6c554387@beavis.confused.org> <20071029084232.GA2280@ff.dom.local> <20071029.014147.56411400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: darko.koruga@siol.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:42162 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754087AbXJ3OHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 10:07:49 -0400
Content-Disposition: inline
In-Reply-To: <20071029.014147.56411400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 01:41:47AM -0700, David Miller wrote:
...
> Actually, this was caused by a real bug in the SKB_WITH_OVERHEAD macro
> definition, which Herbert Xu quickly spotted and fixed.
> 
> Which "I hope you've found this by yourself by now".
> 

...Btw, of course you have to be right, and I should find this in max.
12 days yet, if I'm as smart as I hope. But as for now, I really can't
see any meaningful difference between this "buggy" SKB_WITH_OVERHEAD
version and 'generic' 2.6.20.

There is also a tiny doubt, how this all could influence 2.6.21-rc4,
which seems to be 'generic' here as well. I guess it has to be some
git issue... the more so, as I can't see there this other (bisected)
patch as well?! Then, of course, this could be my sight issue - but
then these 12 days are definitely not enough...

Cheers,
Jarek P.
