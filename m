From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 12:14:12 -0700
Message-ID: <20080415121412.530f6309@extreme>
References: <20080414213238.GB28833@kroah.com>
	<1208271789.20681.45.camel@FWR-FLAB>
	<20080415153408.GB7996@kroah.com>
	<200804152046.44018.oliver@neukum.org>
	<20080415190030.GB27608@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>, Filip Aben <f.aben@option.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44670 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753206AbYDOTOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:14:20 -0400
In-Reply-To: <20080415190030.GB27608@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Apr 2008 12:00:30 -0700
Greg KH <greg@kroah.com> wrote:

> On Tue, Apr 15, 2008 at 08:46:42PM +0200, Oliver Neukum wrote:
> > Am Dienstag, 15. April 2008 17:34:08 schrieb Greg KH:
> > > So I'll go delete that "special" ioctl, that's not a good thing to do,
> > > use the common interfaces that all USB devices rely on instead, don't do
> > > something different for just one type of USB device.
> > 
> > Do you have a new unified patch? I'd work against that, lest we get
> > merge troubles.
> 
> Good idea :)
> 
> Here it is.
> 
> thanks,
> 
> greg k-h
> 
> ----------------
> 
> Subject: USB: add option hso driver
> 
> This driver is for a number of different Option devices.  Originally
> written by Option and Andrew Bird, but cleaned up massivly for
> acceptance into mainline by me (Greg).
> 
> TODO:
> 	- remove proc files and move to debugfs
> 	- review network interfaces
> 	- add better changelog information

More work left:

- Use netif_msg_ for the message level rather than module parameter
- net_device_stats are now available in dev->stats
- use ethtool_ops rather than ioctl

