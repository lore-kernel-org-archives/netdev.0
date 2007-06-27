From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Wed, 27 Jun 2007 07:44:16 -0700
Message-ID: <20070627144416.GA28899@kroah.com>
References: <87myyl6df1.fsf@nanv.dk> <46821E80.8080105@garzik.org> <200706270154.16022.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Peter Korsgaard <jacmet@sunsite.dk>,
	netdev@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:36350 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759097AbXF0PKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 11:10:44 -0400
Content-Disposition: inline
In-Reply-To: <200706270154.16022.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 27, 2007 at 01:54:15AM -0700, David Brownell wrote:
> On Wednesday 27 June 2007, Jeff Garzik wrote:
> > Peter Korsgaard wrote:
> > > Questions regarding the USB network drivers should now go to netdev.
> > > 
> > > Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> > > ---
> > >  MAINTAINERS |   13 +++++--------
> > >  1 file changed, 5 insertions(+), 8 deletions(-)
> > > 
> > > Index: linux-2.6.22-rc6/MAINTAINERS
> > > ===================================================================
> > > --- linux-2.6.22-rc6.orig/MAINTAINERS
> > > +++ linux-2.6.22-rc6/MAINTAINERS
> > > @@ -3610,15 +3610,14 @@
> > >  USB CDC ETHERNET DRIVER
> > >  P:	Greg Kroah-Hartman
> 
> I think that may refer to the old cdc ethernet driver
> though ... Greg?  The new one, in the usbnet framework,
> is a very different beast...

Yeah, this is the cdc_acm driver that is still in the USB drivers/
directory tree as it is a USB class driver that shows up as a tty device
to userspace.  It should not be moved to the networking list unless no
one minds that I never see any queries about it :)

thanks,

greg k-h
