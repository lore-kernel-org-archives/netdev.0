From: Willy Tarreau <w@1wt.eu>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 22:14:31 +0200
Message-ID: <20121019201430.GI17417@1wt.eu>
References: <20121019195557.GG17417@1wt.eu> <20121019.160104.115897882147794932.davem@davemloft.net> <20121019200318.GH17417@1wt.eu> <20121019.160711.1159467896676133280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcrl@kvack.org, stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33812 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399Ab2JSUOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 16:14:37 -0400
Content-Disposition: inline
In-Reply-To: <20121019.160711.1159467896676133280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 04:07:11PM -0400, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Fri, 19 Oct 2012 22:03:18 +0200
> 
> > On Fri, Oct 19, 2012 at 04:01:04PM -0400, David Miller wrote:
> >> From: Willy Tarreau <w@1wt.eu>
> >> Date: Fri, 19 Oct 2012 21:55:57 +0200
> >> 
> >> > On Fri, Oct 19, 2012 at 03:49:30PM -0400, David Miller wrote:
> >> >> 
> >> >> How about checking if these changes are already in 3.0/3.2/etc. or not
> >> >> before asking such questions?
> >> > 
> >> > Because I didn't find the patches in 3.0 and Ben said he backported them
> >> > from 3.6, I think these are two valid reasons to ask, no ?
> >> 
> >> Well, the thing is, I personally don't consider them appropriate for
> >> 3.x.y -stable backports, and that's why I haven't submitted them.
> > 
> > OK. Is is because the issue is less important there or because the fix are
> > more risky than the issues they fix (or any other reason) ?
> 
> I have a different opinion about the risk/benefit ratio than Ben does.
> 
> I do not think these cases are important enough to enough people to
> justify -stable inclusion at all.

OK, thanks for the precision.

So maybe in the end we should just merge d11a4dc18 that Ben found to be
the least invasive one fixing the issues, and we'd be in sync with the
rest of the stable branches, even if, as you noted a few days ago, it's
only a partial fix for the issue.

Ben, what's your opinion on this ? I know it's never fun to do backports
and not merge them later, but I trust David more than anyone else on the
network part, so if he decided that while incomplete, the patch above
was all that was needed for other stable branches, maybe we should just
stay on the safe side and do the same ?

Willy
