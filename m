From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] unix_diag: use netlink attribute MAX convention
Date: Wed, 25 Apr 2012 12:47:43 -0700
Message-ID: <20120425124743.5b4fb8a3@nehalam.linuxnetplumber.net>
References: <20120425103858.04d149d8@nehalam.linuxnetplumber.net>
	<20120425.141658.1934757959636497552.davem@davemloft.net>
	<20120425115609.4ef9ece0@nehalam.linuxnetplumber.net>
	<20120425.150716.1476178549121153876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shanwei88@gmail.com, xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37627 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757829Ab2DYTrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 15:47:47 -0400
In-Reply-To: <20120425.150716.1476178549121153876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Apr 2012 15:07:16 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 25 Apr 2012 11:56:09 -0700
> 
> > Do you expect the one utility to use it to have a workaround for
> > a broken initial version.
> 
> I'm not taking that risk.
> 
> They thought the same exact thing when they did the autofs struct size
> compat fix, and it turned out to break things.
> 
> Stephen I have an awesome suggestion for you if you want to avoid this
> in the future, review iproute2 patches more aggressively so you can
> catch things like this earlier.  Like, when we can actually still
> safely change things.

Sorry it was more of cross project issue in this case. The original
kernel patch had the problem and was lost in the fog of the other
issues like the unix diag implementation not building.

A community works best if multiple people look at the code.
Don't think I would have spotted it unless I compared it to
other places.


> Because currently you let patches rot in patchwork.  There's an
> iproute2 patch in there assigned to you which is 3 months old, that
> simply isn't how this is supposed to work.
> 
> I hate to keep beating a dead horse, but you don't stay on top of
> patchwork like you should.  The object is not to let patches just
> rot in "Under Review" state for months.

I keep patches that are for -next in that state.

> Either you apply them as soon as possible, or you mark them
> appropriately as "Changes Requested" or "Deferred" so that the
> submitter makes appropriate fixes you've asked for, or resubmits when
> it's more appropriate for the change to go in.
> 
> "Under Review" doesn't mean, "I'm waiting for a kernel release with
> the feature".  But that's how you use it.

Ok. What is the suggested tag for that.
