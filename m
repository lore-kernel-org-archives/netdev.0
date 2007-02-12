From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 12:20:58 -0800 (PST)
Message-ID: <20070212.122058.63127043.davem@davemloft.net>
References: <20070212160317.545906075@linux-foundation.org>
	<20070212160336.681729431@linux-foundation.org>
	<20070212191101.GP25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49738
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965302AbXBLUU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:20:59 -0500
In-Reply-To: <20070212191101.GP25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Mon, 12 Feb 2007 21:11:01 +0200

> Since no one really agrees on the relative merits and problems of the
> different algorithms and since the users themselves dont know, dont care
> and have no clue on what should be the correct behaviour to report bugs
> (see the old bic bugs, the htcp bugs, the recent sack bugs) I would
> suggest to avoid making the whole internet a guinea pig and get back to
> reno. If someone really needs to push high BDP flows he should test it
> himself and choose what works for his kernel at the time.
> 
> For myself and anyone who asks me I recommend to set the default to
> reno. For the few who really need high speed flows, they should test
> kernel and protocol combination.

We have "high BDP flows" even going from between the east and the west
coast of the United States.

This doesn't even begin to touch upon extremely well connected
coutries like South Korea and what happens when people there try to
access sites in Europe or the US.

Good high BDP flow handling is necessary now and for everyday usage of
the internet, it's not some obscure thing only researchers in fancy
labs need.

This also isn't the internet of 15 years ago where IETF members can
spend 4 or 5 years masterbating over new ideas before deploying them.
I know that's what conservative folks want, but it isn't going to
happen.
