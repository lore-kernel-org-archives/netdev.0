From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch 1/2] caif: remove unneeded variable from caif_net_open()
Date: Tue, 1 Jun 2010 09:45:57 +0200
Message-ID: <20100601074557.GJ5483@bicker>
References: <20100601070855.GD5483@bicker> <4C04B646.9080506@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49947 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab0FAHqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:46:14 -0400
Content-Disposition: inline
In-Reply-To: <4C04B646.9080506@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 01, 2010 at 09:27:02AM +0200, walter harms wrote:
> >  static int caif_net_open(struct net_device *dev)
> >  {
> > -	struct ser_device *ser;
> > -	ser = netdev_priv(dev);
> >  	netif_wake_queue(dev);
> >  	return 0;
> >  }
> 
> 
> what makes caif_net_open() obsolet ?
> 

No.  It has to return an int to match this:
        int                     (*ndo_open)(struct net_device *dev);

regards,
dan carpenter
