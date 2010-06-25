From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Fri, 25 Jun 2010 20:08:22 +1000
Message-ID: <20100625100822.GX10441@laptop>
References: <20100624182123.45264dfe.akpm@linux-foundation.org>
 <20100624.203006.35035648.davem@davemloft.net>
 <20100624205059.a28756b0.akpm@linux-foundation.org>
 <20100624.212713.242141362.davem@davemloft.net>
 <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.hengli.com.au,
	mst@redhat.com, frzhang@redhat.com, netdev@vger.kernel.org,
	amwang@redhat.com, shemminger@vyatta.com, mpm@selenic.com,
	paulmck@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, mingo@elte.hu
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:44843 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304Ab0FYKI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 06:08:28 -0400
Content-Disposition: inline
In-Reply-To: <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 24, 2010 at 09:42:04PM -0700, Andrew Morton wrote:
> On Thu, 24 Jun 2010 21:27:13 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Thu, 24 Jun 2010 20:50:59 -0700
> > 
> > > What happens if you want to actually *drop* a patch from net-next? 
> > > Surely that happens?
> > 
> > I've only respun the tree on two or three occasions and that was
> > because I made some significant error myself and screwed up the
> > GIT tree somehow.
> > 
> > We've fixed much worse bugs than this one weeks after the changes
> > causing them went in, life goes on.
> 
> Still sucks - this is a quite ugly drawback to how we're using git. 
> I've hit bisection holes several times which held up the show. 
> Sometimes you can make them go away by fiddling the .config, other
> times I've hunted down the fix and manually applied it for each
> iteration.  It makes me feel all guilty each time I ask some poor sap
> to bisect a bug for us.

This might be somewhat improved by tagging a fix with the id of the
patch causing the regression, so that bisect could go through and try
to apply a fix out of order.

This could be done with a specific note format in the changelog, but
I don't know whether it's realistic to support in git format or if
you'd have to have a tool that builds up a mapping going the other
way...

Could also be useful for distros backporting things.

