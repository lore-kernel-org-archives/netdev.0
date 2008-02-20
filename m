From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [git patches] net driver fixes
Date: Wed, 20 Feb 2008 17:25:30 -0500
Message-ID: <20080220222530.GK30160@fieldses.org>
References: <20080220165557.GA18816@havoc.gtf.org> <20080220.131530.18314167.davem@davemloft.net> <20080220212302.GJ30160@fieldses.org> <20080220.134257.41491836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45071 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129AbYBTWZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 17:25:33 -0500
Content-Disposition: inline
In-Reply-To: <20080220.134257.41491836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2008 at 01:42:57PM -0800, David Miller wrote:
> From: "J. Bruce Fields" <bfields@fieldses.org>
> Date: Wed, 20 Feb 2008 16:23:02 -0500
> 
> > On Wed, Feb 20, 2008 at 01:15:30PM -0800, David Miller wrote:
> > > From: Jeff Garzik <jeff@garzik.org>
> > > Date: Wed, 20 Feb 2008 11:55:57 -0500
> > > 
> > > > 
> > > > Note:  this is based off of Linus's latest commit
> > > > (5d9c4a7de64d398604a978d267a6987f1f4025b7), since all my previous
> > > > submissions are now upstream (thanks!).
> > > 
> > > The whole point of my not rebasing net-2.6 is so that you can always
> > > use it as a base.
> > > 
> > > With what you've giving me now I either have to:
> > > 
> > > 1) Pull in Linus's tree to net-2.6, then pull from you.
> > > 
> > > 2) Pull in directly from you to get it all.
> > 
> > Why are either of those a problem?
> 
> Because it forces me to pull Linus's upstream into net-2.6,
> I don't have any choice in the matter.

Right.  I'm wondering what the problems are that you see with that.

The advantages include earlier warning of merge problems, and avoidance
of duplicate commits--if Jeff's done work that depends on patches that
already upstream, then he either does that work against upstream, or
includes backported patches in the branch he asks you to pull, and you
end up with both the original and the backported patch.  Which isn't the
end of the world, but the resulting history seems messier than
necessary.

Or I guess you could both wait to do this merge until you're ready to
pull in Linus's latest?

For non-git-using testers there may be an advantage to always keeping a
tree based on the latest tagged release, as it may simplify providing
them with patches in some cases.  But if the goal is to provide a basis
for other maintainer's work, I'd've thought the best policy would be
just to track the tip of every relevant branch (which includes Linus's
in this case).

--b.
