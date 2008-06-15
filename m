From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: dm9000: Remove the 2 resources probe scheme.
Date: Sun, 15 Jun 2008 22:49:04 +0100
Message-ID: <20080615214904.GR31817@trinity.fluff.org>
References: <200806131458.58410.laurentp@cse-semaphore.com> <386072610806130729k77d1801lb615ffafb3d0117f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laurent Pinchart <laurentp@cse-semaphore.com>,
	netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.fluff.org ([89.145.97.151]:59613 "EHLO
	trinity.fluff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbYFOVtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 17:49:12 -0400
Content-Disposition: inline
In-Reply-To: <386072610806130729k77d1801lb615ffafb3d0117f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2008 at 10:29:45PM +0800, Bryan Wu wrote:
> On Fri, Jun 13, 2008 at 8:58 PM, Laurent Pinchart
> <laurentp@cse-semaphore.com> wrote:
> > The dm9000 driver accepts either 2 or 3 resources to describe the platform
> > devices. The 2 resources case abuses the ioresource mechanism by passing
> > ioremap()ed memory through the platform device resources. This patch removes
> > that case and converts boards that were using it to the 3 resources scheme.
> >
> > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > ---
> >  arch/blackfin/mach-bf527/boards/ezkit.c         |    7 ++-
> >  arch/blackfin/mach-bf533/boards/H8606.c         |    7 ++-
> >  arch/blackfin/mach-bf537/boards/generic_board.c |    7 ++-
> >  arch/blackfin/mach-bf537/boards/stamp.c         |    7 ++-
> 
> IMO, this patch can be split into two parts, one for Blackfin and the
> other for dm9000 driver.

I think I agree with that, although I would also like to make sure the
blackfin part of this is tested. I am also trying to get rid of the
defines for blackfin specific compile, as they shouldn't be in the
driver!

I've queued the dm9000 specific bits into my own little dm9000 tree
for the next kernel release.

-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.

