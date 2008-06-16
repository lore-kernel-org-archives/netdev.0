From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: dm9000: Remove the 2 resources probe scheme.
Date: Mon, 16 Jun 2008 14:09:07 +0100
Message-ID: <20080616130907.GB26276@fluff.org.uk>
References: <200806131458.58410.laurentp@cse-semaphore.com> <386072610806130729k77d1801lb615ffafb3d0117f@mail.gmail.com> <20080615214904.GR31817@trinity.fluff.org> <200806161046.50534.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, Bryan Wu <cooloney@kernel.org>,
	netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:65049 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753142AbYFPNJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 09:09:34 -0400
Content-Disposition: inline
In-Reply-To: <200806161046.50534.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 10:46:48AM +0200, Laurent Pinchart wrote:
> On Sunday 15 June 2008 23:49, Ben Dooks wrote:
> > On Fri, Jun 13, 2008 at 10:29:45PM +0800, Bryan Wu wrote:
> > > On Fri, Jun 13, 2008 at 8:58 PM, Laurent Pinchart
> > > <laurentp@cse-semaphore.com> wrote:
> > > > The dm9000 driver accepts either 2 or 3 resources to describe the
> > > > platform devices. The 2 resources case abuses the ioresource mechanism
> > > > by passing ioremap()ed memory through the platform device resources.
> > > > This patch removes that case and converts boards that were using it to
> > > > the 3 resources scheme. 
> > > >
> > > > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > > > ---
> > > >  arch/blackfin/mach-bf527/boards/ezkit.c         |    7 ++-
> > > >  arch/blackfin/mach-bf533/boards/H8606.c         |    7 ++-
> > > >  arch/blackfin/mach-bf537/boards/generic_board.c |    7 ++-
> > > >  arch/blackfin/mach-bf537/boards/stamp.c         |    7 ++-
> > > 
> > > IMO, this patch can be split into two parts, one for Blackfin and the
> > > other for dm9000 driver.
> > 
> > I think I agree with that, although I would also like to make sure the
> > blackfin part of this is tested. I am also trying to get rid of the
> > defines for blackfin specific compile, as they shouldn't be in the
> > driver!
> > 
> > I've queued the dm9000 specific bits into my own little dm9000 tree
> > for the next kernel release.
> 
> Thanks. Should I resubmit a blackfin-specific patch (I obviously won't be able 
> to test it, as I have no blackfin hardware) or will you take care of it ?

I'll sort out the rest of the split and removing the other blackfin
cruft from the driver.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
