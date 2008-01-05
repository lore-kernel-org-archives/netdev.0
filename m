From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sun, 06 Jan 2008 07:53:06 +1100
Message-ID: <1199566386.7291.58.camel@pasglop>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	 <1199528388.7291.55.camel@pasglop>  <200801051338.17957.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50493 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654AbYAEUxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 15:53:32 -0500
In-Reply-To: <200801051338.17957.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-01-05 at 13:38 +0100, Stefan Roese wrote:
> On Saturday 05 January 2008, Benjamin Herrenschmidt wrote:
> > On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> > > Performance tests done by AMCC have shown that 256 buffer increase the
> > > performance of the Linux EMAC driver. So let's update the default
> > > values to match this setup.
> > >
> > > Signed-off-by: Stefan Roese <sr@denx.de>
> > > ---
> >
> > Do we have the numbers ? Did they also measure latency ?
> 
> I hoped this question would not come. ;) No, unfortunately I don't have any 
> numbers. Just the recommendation from AMCC to always use 256 buffers.

Ok. Well, it's just a .config option so I suppose the patch is fine. Can
you also update the defconfigs (at least for the recent AMCC boards) ?

Ben.


