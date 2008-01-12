From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 12 Jan 2008 08:26:52 +0100
Message-ID: <200801120826.53091.sr@denx.de>
References: <1199526609-12290-1-git-send-email-sr@denx.de> <20080111174822.GB17240@gate.ebshome.net> <1200089457.6896.65.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eugene Surovegin <ebs@ebshome.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:51010 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760936AbYALH0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 02:26:55 -0500
In-Reply-To: <1200089457.6896.65.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008, Benjamin Herrenschmidt wrote:
> On Fri, 2008-01-11 at 09:48 -0800, Eugene Surovegin wrote:
> > On Sat, Jan 05, 2008 at 01:38:17PM +0100, Stefan Roese wrote:
> > > On Saturday 05 January 2008, Benjamin Herrenschmidt wrote:
> > > > On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> > > > > Performance tests done by AMCC have shown that 256 buffer increase
> > > > > the performance of the Linux EMAC driver. So let's update the
> > > > > default values to match this setup.
> > > > >
> > > > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > > > ---
> > > >
> > > > Do we have the numbers ? Did they also measure latency ?
> > >
> > > I hoped this question would not come. ;) No, unfortunately I don't have
> > > any numbers. Just the recommendation from AMCC to always use 256
> > > buffers.
> >
> > This cannot be true for all chips. Default numbers I selected weren't
> > random. In particular, 256 for Tx doesn't make a lot of sense for 405.
> > You just gonna waste memory.

This may be the case with the "old" 405 PPC's. But with the new ones coming 
out right now, like the up to 666MHz 405EX with GBit support, 256 could be an 
improvement. I still owe you figures though. Will try to do some testing in a 
short while.

> > I'd be quite reluctant to follow such advices from AMCC without actual
> > details.
>
> I think we can make defaults based on other config options nowadays. Not
> very nice but we could do things like
>
> 	default 128 if PPC_40x
> 	default 256
>
> Or even more detailed.

We shouldn't make it too complicated. We can always select different settings 
in the defconfig file. My thinking here is to better wast a little memory 
with a potential performance improvement. Just me 0.02$

Best regards,
Stefan
