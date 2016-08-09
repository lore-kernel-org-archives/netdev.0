From: Jiri Kosina <jikos@kernel.org>
Subject: Re: qdisc hash table changes...
Date: Tue, 9 Aug 2016 11:02:43 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608091101220.22028@cbobk.fhfr.pm>
References: <20160808.155335.2122819330212870390.davem@davemloft.net> <alpine.LNX.2.00.1608090936180.22028@cbobk.fhfr.pm> <20160809.015417.214949723922909511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38946 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbcHIJCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 05:02:45 -0400
In-Reply-To: <20160809.015417.214949723922909511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Aug 2016, David Miller wrote:

> > It does indirectly pull in some networking headers, but it doesn't pull in 
> > netdevice.h (which is the place where the actual include of hashtable.h 
> > happens):
> 
> It pulls in skbuff.h, so are you willing to bet forever that skbuff.h
> won't indirectly pull in netdevice.h at some point in the future?
> 
> This is obviously a big problem, having global namespace conflicts
> like this.
> 
> Pushing fixing it propering into the future isn't really the right
> thing to do.
> 
> So please entertain my request to do this properly.

Ok, I will add this to my TODO list, but this can take quite some time 
(especially as I can imagine some maintainers pushing back on this, 
because it doesn't really fix any existing issue in their code).

Does that strictly have to be a show-stopper for the qdisc hash 
conversion, given the fact that the whole tree is building properly?

> Thank you.

Thanks,

-- 
Jiri Kosina
SUSE Labs
