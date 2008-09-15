From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 16:45:43 -0400
Message-ID: <20080915204543.GD3994@havoc.gtf.org>
References: <20080913203548.GA2989@havoc.gtf.org> <20080915.120917.36004302.davem@davemloft.net> <20080915201749.GB3994@havoc.gtf.org> <20080915.132716.267218808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49476 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926AbYIOUpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 16:45:46 -0400
Content-Disposition: inline
In-Reply-To: <20080915.132716.267218808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 01:27:16PM -0700, David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Mon, 15 Sep 2008 16:17:50 -0400
> 
> > On Mon, Sep 15, 2008 at 12:09:17PM -0700, David Miller wrote:
> > > From: Jeff Garzik <jeff@garzik.org>
> > > Date: Sat, 13 Sep 2008 16:35:48 -0400
> > > 
> > > > Includes several fixes from my slice of the akpm patch pie.
> > > 
> > > Which of these have regression and/or bugzilla entries?
> > > 
> > > This is too much and I want to see it trimmed down.
> > 
> > What do you not want?  The two warning fixes (mlx4, cs89x0) akpm seemed
> > to want in 2.6.27, the 8139too change is cosmetic.  The other stuff is
> > critical AFAICS.
> 
> I'll take another look at the queue and try to give you some
> more specific feedback.
> 
> I can think of about 3 or 4 entries on the posted regression
> list that might be appropriate, so I essentially expected to
> see that many commits, give or take one or two.

Don't stick strictly to that list...  We want an oops fix even if
the oops is present in 2.6.26.  We want a spinlock fix that makes a
driver work properly on SMP, even if that bug is present in 2.6.26.  We
want a build fix, etc.

	Jeff



