From: Baruch Even <baruch@ev-en.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 00:12:41 +0200
Message-ID: <20070212221241.GQ25760@galon.ev-en.org>
References: <20070212160317.545906075@linux-foundation.org> <20070212160336.681729431@linux-foundation.org> <20070212191101.GP25760@galon.ev-en.org> <20070212.122058.63127043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:59221
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030206AbXBLWMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 17:12:43 -0500
Content-Disposition: inline
In-Reply-To: <20070212.122058.63127043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070212 22:21]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Mon, 12 Feb 2007 21:11:01 +0200
> 
> > Since no one really agrees on the relative merits and problems of the
> > different algorithms and since the users themselves dont know, dont care
> > and have no clue on what should be the correct behaviour to report bugs
> > (see the old bic bugs, the htcp bugs, the recent sack bugs) I would
> > suggest to avoid making the whole internet a guinea pig and get back to
> > reno. If someone really needs to push high BDP flows he should test it
> > himself and choose what works for his kernel at the time.
> > 
> > For myself and anyone who asks me I recommend to set the default to
> > reno. For the few who really need high speed flows, they should test
> > kernel and protocol combination.
> 
> We have "high BDP flows" even going from between the east and the west
> coast of the United States.
> 
> This doesn't even begin to touch upon extremely well connected
> coutries like South Korea and what happens when people there try to
> access sites in Europe or the US.
> 
> Good high BDP flow handling is necessary now and for everyday usage of
> the internet, it's not some obscure thing only researchers in fancy
> labs need.
> 
> This also isn't the internet of 15 years ago where IETF members can
> spend 4 or 5 years masterbating over new ideas before deploying them.
> I know that's what conservative folks want, but it isn't going to
> happen.

The problem is that you actually put a mostly untested algorithm as the
default for everyone to use. The BIC example is important, it was the
default algorithm for a long while and had implementation bugs that no
one cared for. The behaviour of cubic wasn't properly verified as the
algorithm in the linux kernel is not the one that was actually proposed
and you intend to make it the default without sufficient testing, that
seems to me to be quite unreasonable.

As to the reasoning that the new algorithms are supposed to act like
Reno, that needs to be verified as well, it's not evident from the code
itself.

Baruch
