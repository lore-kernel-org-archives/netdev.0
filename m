From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 12:27:57 -0700
Message-ID: <20080415192757.GB27592@kroah.com>
References: <20080414213238.GB28833@kroah.com> <1208271789.20681.45.camel@FWR-FLAB> <20080415153408.GB7996@kroah.com> <200804152046.44018.oliver@neukum.org> <20080415190030.GB27608@kroah.com> <20080415121412.530f6309@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oliver@neukum.org>, Filip Aben <f.aben@option.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60935 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762244AbYDOT23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 15:28:29 -0400
Content-Disposition: inline
In-Reply-To: <20080415121412.530f6309@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 12:14:12PM -0700, Stephen Hemminger wrote:
> > TODO:
> > 	- remove proc files and move to debugfs
> > 	- review network interfaces
> > 	- add better changelog information
> 
> More work left:
> 
> - Use netif_msg_ for the message level rather than module parameter
> - net_device_stats are now available in dev->stats
> - use ethtool_ops rather than ioctl

Thanks, I've added them to the TODO list.

greg k-h
