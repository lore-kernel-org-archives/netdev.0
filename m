From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Sat, 20 Sep 2008 00:24:20 -0700 (PDT)
Message-ID: <20080920.002420.267472325.davem@davemloft.net>
References: <20080915.132716.267218808.davem@davemloft.net>
	<20080915.141159.181213705.davem@davemloft.net>
	<20080916020100.GA23389@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750736AbYITHYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 03:24:33 -0400
In-Reply-To: <20080916020100.GA23389@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 16 Sep 2008 12:01:18 +1000

> On Mon, Sep 15, 2008 at 02:11:59PM -0700, David Miller wrote:
> 
> [snip]
> > 
> > Not a 2.6.27 regression, this problem has been there forever.
> > 
> > 	Magnus Damm (2):
> > 	      smc91x: fix nowait printout
> > 
> > This one is good but the commit message needs to be fixed up.
> > It references a raw SHA1 ID but does not give the commit message
> > header line as well, which is a requirement.
> > 
> >       smc91x: SMC_IO_SHIFT platform data support for default case
> > 
> > Ok, but needs commit header line text for referenced commit.
> 
> can you confirm that the commit message requirement stands even
> if the SHA1 ID references Linus' tree? I personally think that is
> reasonable, I just want to confirm that is the requirement.

Yes, because the commit messages will propagate back usually
verbatim for changes backported into the -stable branches.
