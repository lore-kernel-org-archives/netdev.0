From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 12 Jan 2008 09:10:57 +1100
Message-ID: <1200089457.6896.65.camel@pasglop>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	 <1199528388.7291.55.camel@pasglop> <200801051338.17957.sr@denx.de>
	 <20080111174822.GB17240@gate.ebshome.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34786 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760383AbYAKWLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 17:11:24 -0500
In-Reply-To: <20080111174822.GB17240@gate.ebshome.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-01-11 at 09:48 -0800, Eugene Surovegin wrote:
> On Sat, Jan 05, 2008 at 01:38:17PM +0100, Stefan Roese wrote:
> > On Saturday 05 January 2008, Benjamin Herrenschmidt wrote:
> > > On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> > > > Performance tests done by AMCC have shown that 256 buffer increase the
> > > > performance of the Linux EMAC driver. So let's update the default
> > > > values to match this setup.
> > > >
> > > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > > ---
> > >
> > > Do we have the numbers ? Did they also measure latency ?
> > 
> > I hoped this question would not come. ;) No, unfortunately I don't have any 
> > numbers. Just the recommendation from AMCC to always use 256 buffers.
> 
> This cannot be true for all chips. Default numbers I selected weren't 
> random. In particular, 256 for Tx doesn't make a lot of sense for 405. 
> You just gonna waste memory.
> 
> I'd be quite reluctant to follow such advices from AMCC without actual 
> details. 

I think we can make defaults based on other config options nowadays. Not
very nice but we could do things like

	default 128 if PPC_40x
	default 256

Or even more detailed.

Cheers,
Ben.


