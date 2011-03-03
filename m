From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: bonding...
Date: Thu, 3 Mar 2011 11:04:04 -0500
Message-ID: <20110303160404.GO11864@gospo.rdu.redhat.com>
References: <20110302.214910.112578818.davem@davemloft.net> <20110303114539.GB5146@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab1CCQEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 11:04:14 -0500
Content-Disposition: inline
In-Reply-To: <20110303114539.GB5146@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2011 at 06:45:39AM -0500, Neil Horman wrote:
> On Wed, Mar 02, 2011 at 09:49:10PM -0800, David Miller wrote:
> > 
> > Hey, if someone could step up and help with bonding maintainence
> > in some tangible way, I'd really appreciate it.
> > 
> > Currently the situation is that many people work on bonding patches,
> > and whilst I do try and wait for some ACKs to arrive, I am the person
> > who has to sort out when changes are ready, decide to apply them, and
> > poke for review when things fall through the cracks.
> > 
> > Sometimes patches go for weeks without ACKs, and in that situation
> > I have to either try to understand the changes myself, or wait
> > potentially forever for someone with bonding knowledge to take a
> > good look at the patch and properly review it.
> > 
> > It was nearly 2 weeks before Oleg V. Ukhno's 802.3ad round-robin patch
> > got looked at by anyone with bonding knowledge.  And it only happened
> > because I got tired of seeing his poor patch rot in patchwork
> > and had to explicitly asked for review the other day.
> > 
> > This is unacceptable, people are submitting multiple bonding patches
> > every single day now.  It needs a clueful bonding person looking at
> > these submissions on a constant basis.
> > 
> > This is a serious problem and is backlogging the netdev patch queue.
> > 
> > So if someone would become an active bonding patch-accumulator, and
> > send me sets of patches that are ready to apply, I would really
> > appreciate it.
> > 
> > Thanks.
> I nominate gospo.  If he doesn't want to, I can do it
> Neil
> 

I would be willing to do it, but my one of my goals would be to prevent
some of the feature creep we are currently seeing with bonding (as Ben
has suggested).  That doesn't mean I want to stop all new features, but
at this point things are starting to get out of control. I suspect this
is why Jay has struggled to keep up with the patches.

I would also want to look at a restructuring of the configuration.  The
lines are starting to blur between some of the modes and output port
selection for other modes and that needs to be cleared up.

How does that sound?

-andy

