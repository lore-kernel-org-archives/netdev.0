From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] cdc_subset: deal with a device that needs reset for
 timeout
Date: Mon, 28 Jul 2014 10:13:11 +0200
Message-ID: <1406535191.17754.10.camel@linux-fkkt.site>
References: <1406203174-13102-1-git-send-email-oneukum@suse.de>
	 <20140727.223131.562363351418867070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46262 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbaG1INo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 04:13:44 -0400
In-Reply-To: <20140727.223131.562363351418867070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-07-27 at 22:31 -0700, David Miller wrote:
> From: Oliver Neukum <oneukum@suse.de>
> Date: Thu, 24 Jul 2014 13:59:34 +0200
> 
> > @@ -1218,6 +1218,8 @@ void usbnet_tx_timeout (struct net_device *net)
> >  
> >  	unlink_urbs (dev, &dev->txq);
> >  	tasklet_schedule (&dev->bh);
> > +	if (dev->driver_info->recover)
> > +		(dev->driver_info->recover)(dev);
> >  
> >  	// FIXME: device recovery -- reset?
> >  }
> 
> Well, since you're at least providing a way to handle this now, you can
> remove this comment completely.

Certainly

	Sorry
		Oliver
