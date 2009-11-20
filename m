From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Network hangs with 2.6.30.5
Date: Fri, 20 Nov 2009 14:09:35 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911201406210.7024@wel-95.cs.helsinki.fi>
References: <20090907072143.GA5966@ff.dom.local> <20091001.154913.88345178.davem@davemloft.net> <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi> <20091119.154038.194307613.davem@davemloft.net> <20091120120452.GA11462@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	holger.hoffstaette@googlemail.com, Netdev <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38252 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbZKTMJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 07:09:30 -0500
In-Reply-To: <20091120120452.GA11462@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Nov 2009, Evgeniy Polyakov wrote:

> On Thu, Nov 19, 2009 at 03:40:38PM -0800, David Miller (davem@davemloft.net) wrote:
> > >> I also looked through all the TCP commits in 2.6.29 to 2.6.30
> > >> and I could not find anything else that might cause stalls with
> > >> time-wait recycled connections.
> > > 
> > > What about the more than 64k connections change a9d8f9110d7e953c2f2 (or 
> > > its fixes), it might be another possibility? ...It certainly does 
> > > something related to reuse and happens to be in the correct time frame... 
> > > (I've added Evgeniy).
> > 
> > So I've been studying this one quite a bit.
> > 
> > This change could only cause problems in timewait recycling if it:
> > 
> > 1) Would accept using a bind bucket that previously it would not
> > 
> > 2) Caused socket corruption due to bad locking
> > 
> > And I can find neither problem with the Evgeniy's bind changes.
> > 
> > So we've back to square one I think.
> 
> Wasn't solution found for this problem, I recall related discussion
> recently, or should I dig deeper into this one?

Nothing that I know off (but that's not too reassuring I'd say). IIRC, 
there were two independent problems same looking problems and one of them 
turned out to be related to something else while the other problem 
withstands but that guy's hw broke so the test case will no longer be 
available or something like that.

-- 
 i.
