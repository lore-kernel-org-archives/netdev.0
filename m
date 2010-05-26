From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 23:27:45 +0200
Message-ID: <20100526212745.GC24615@basil.fritz.box>
References: <20100525.225236.226781050.davem@davemloft.net> <AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com> <87fx1e1sat.fsf@basil.nowhere.org> <20100526.140818.245406045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34928 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab0EZV1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 17:27:51 -0400
Content-Disposition: inline
In-Reply-To: <20100526.140818.245406045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Yes all of Saudi-Arabia used to be (is?) one IP address...
> > 
> > Caching anything per IP is bogus.
> 
> And letting the applications choose the CWND is better?!?!

No I actually agree with you on that. Just saying that
anything that relies on per IP caching is bad too.

As I understand the idea was that the application knows
what flows belong to a single peer and wants to have
a single cwnd for all of those. Perhaps there would
be a way to generalize that to tell it to the kernel.

e.g. have a "peer id"  that is known by applications
and the kernel could manage cwnds shared between connections
associated with the same peer id?

Just an idea, I admit I haven't thought very deeply
about this. Feel free to poke holes into it.

-Andi
