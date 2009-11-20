From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Network hangs with 2.6.30.5
Date: Fri, 20 Nov 2009 15:04:52 +0300
Message-ID: <20091120120452.GA11462@ioremap.net>
References: <20090907072143.GA5966@ff.dom.local> <20091001.154913.88345178.davem@davemloft.net> <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi> <20091119.154038.194307613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, jarkao2@gmail.com,
	holger.hoffstaette@googlemail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:50557 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751887AbZKTMEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 07:04:48 -0500
Content-Disposition: inline
In-Reply-To: <20091119.154038.194307613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Nov 19, 2009 at 03:40:38PM -0800, David Miller (davem@davemloft.net) wrote:
> >> I also looked through all the TCP commits in 2.6.29 to 2.6.30
> >> and I could not find anything else that might cause stalls with
> >> time-wait recycled connections.
> > 
> > What about the more than 64k connections change a9d8f9110d7e953c2f2 (or 
> > its fixes), it might be another possibility? ...It certainly does 
> > something related to reuse and happens to be in the correct time frame... 
> > (I've added Evgeniy).
> 
> So I've been studying this one quite a bit.
> 
> This change could only cause problems in timewait recycling if it:
> 
> 1) Would accept using a bind bucket that previously it would not
> 
> 2) Caused socket corruption due to bad locking
> 
> And I can find neither problem with the Evgeniy's bind changes.
> 
> So we've back to square one I think.

Wasn't solution found for this problem, I recall related discussion
recently, or should I dig deeper into this one?

-- 
	Evgeniy Polyakov
