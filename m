From: Greg KH <greg@kroah.com>
Subject: Re: Problem with atl1 and msi in kernel 2.6.22-rc3
Date: Wed, 30 May 2007 15:07:39 -0700
Message-ID: <20070530220739.GA26408@kroah.com>
References: <200705300200.25412.jareguero@telefonica.net> <20070530064711.570162f1@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jose Alberto Reguero <jareguero@telefonica.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:54617 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759298AbXE3WGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 18:06:31 -0400
Content-Disposition: inline
In-Reply-To: <20070530064711.570162f1@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 06:47:11AM -0500, Jay Cliburn wrote:
> On Wed, 30 May 2007 02:00:25 +0200
> Jose Alberto Reguero <jareguero@telefonica.net> wrote:
> 
> > I have problems with a M2V motherboard and atl1 driver with msi and
> > kernel 2.6.22-rc3. With kernel 2.6.21 I had no problems.
> > I must add in drivers/pci/quirks.c (line 1723):
> > 
> >  DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATI, PCI_DEVICE_ID_ATI_RS480, 
> > quirk_disable_msi);
> > +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, 0xe238,
> > quirk_disable_msi);
> > 
> > to disable msi in the atl1.
> 
> See http://bugzilla.kernel.org/show_bug.cgi?id=8472.
> 
> A more general solution is to disable MSI for the VIA VT3351 (used by
> the Asus M2V).  I attempted to do this in the -stable tree with
> http://lkml.org/lkml/2007/5/26/167, but it was shot down because the
> patch isn't upstream yet.
> 
> Unfortunately, I can't submit it upstream because the enabling
> patch hasn't yet been applied upstream by the PCI maintainer. My
> request for info on the status of the patch went unanswered.
> http://lkml.org/lkml/2007/5/19/74

Sorry, I'm catching up on PCI stuff right now (am traveling in Tokyo
right now, gotta love jet lag...)

thanks for your patience.

greg k-h
