From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: tbench wrt. loopback TSO
Date: Mon, 27 Oct 2008 22:35:02 +0300
Message-ID: <20081027193502.GA2590@ioremap.net>
References: <20081027141332.GA4691@ioremap.net> <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi> <20081027170314.GA25148@ioremap.net> <20081027.113904.211811887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:56594 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbYJ0TfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 15:35:05 -0400
Content-Disposition: inline
In-Reply-To: <20081027.113904.211811887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2008 at 11:39:04AM -0700, David Miller (davem@davemloft.net) wrote:
> One idea immediately occurs to me.  Since we're effectively limited
> to a 64K TSO frame, and the MSS is some value smaller than that, we
> can probably get away with a reciprocol divide.  Even using a 16-bit
> inverse value would suffice, so we wouldn't need to use u64's like
> some other pieces of code do.  A u32 would be enough.

But why do we need to trim that last bytes at the first place at all?
Is it just enough to 'binary and' with 0xffff? Or is it what you mean? :)

-- 
	Evgeniy Polyakov
