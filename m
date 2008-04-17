From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Thu, 17 Apr 2008 14:35:09 -0700
Message-ID: <20080417213509.GD17664@kroah.com>
References: <20080414213238.GB28833@kroah.com> <200804152046.44018.oliver@neukum.org> <20080415190030.GB27608@kroah.com> <200804171415.07777.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Filip Aben <f.aben@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51329 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbYDQVs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 17:48:59 -0400
Content-Disposition: inline
In-Reply-To: <200804171415.07777.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2008 at 02:15:06PM +0200, Oliver Neukum wrote:
> Am Dienstag, 15. April 2008 21:00:30 schrieb Greg KH:
> > On Tue, Apr 15, 2008 at 08:46:42PM +0200, Oliver Neukum wrote:
> > > Am Dienstag, 15. April 2008 17:34:08 schrieb Greg KH:
> > > > So I'll go delete that "special" ioctl, that's not a good thing to do,
> > > > use the common interfaces that all USB devices rely on instead, don't do
> > > > something different for just one type of USB device.
> > > 
> > > Do you have a new unified patch? I'd work against that, lest we get
> > > merge troubles.
> > 
> > Good idea :)
> > 
> > Here it is.
> 
> Another one.
> 
> As autosuspend is by default disabled, it makes no sense to have a module
> parameter disabling it. Just don't enable it.

Applied, thanks.

greg k-h
