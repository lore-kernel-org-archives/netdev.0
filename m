From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH-2.4] via-rhine: fix duplex detection issue
Date: Wed, 30 Jul 2008 14:41:39 +0200
Message-ID: <20080730124138.GB2397@1wt.eu>
References: <20080729220802.GA25729@1wt.eu> <20080730095120.GA15833@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2275 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758606AbYG3Mlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 08:41:42 -0400
Content-Disposition: inline
In-Reply-To: <20080730095120.GA15833@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roger,

On Wed, Jul 30, 2008 at 11:51:21AM +0200, Roger Luethi wrote:
> On Wed, 30 Jul 2008 00:08:02 +0200, Willy Tarreau wrote:
> > The user that I am suggest using #1, but the maintainer that
> > I am prefers #2. So I think I'll just go with the patch for
> > the specific issue, and only consider the backport for my
> > personal trees the day I have time to spend on this. That way
> > we get one small patch for one small issue.
> > 
> > I'd like to get your opinion on this, and to check with you
> > if you are basically OK with that change in principle.
> 
> The major changes in 2.6 via-rhine have been in use for quite a while. It's
> clearly an improvement over the one in 2.4 and every bit as stable. I'm not
> sure a backport is worth it, though, especially considering that it's
> incredibly easy to break via-rhine for some odd hardware or use case.
> 
> For 2.4, I'd stay with the devil that I know -- i.e. make minimal changes
> only.

This is exactly the type of information I needed.

> But whatever you decide is fine with me.

Your arguments are more than enough. You know the driver, I don't. Knowing
that you trust it in its current shape is perfect for me. I'll stay on 2.4
version.

> I trust that the 2.4
> maintainer knows what is best for those users. Better than me, anyway.

Hey, I only do what driver authors and maintainers think is reasonable :-)

Thanks very much Roger,
Willy

