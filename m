From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/4] net: smsc911x: Fix register_netdev, phy startup,
 driver unload ordering
Date: Thu, 1 Sep 2016 22:49:23 +0200
Message-ID: <20160901204923.GB16864@lunn.ch>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-3-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com, will.deacon@arm.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752213AbcIAVX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:58 -0400
Content-Disposition: inline
In-Reply-To: <1472760909-19688-3-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -1604,7 +1599,7 @@ static int smsc911x_open(struct net_device *dev)
>  		netdev_warn(dev, "ISR failed signaling test (IRQ %d)\n",
>  			    dev->irq);
>  		retval = -ENODEV;
> -		goto out;
> +		goto mii_free_out;

A nit pick, but it is not really freeing anything.
Maybe you can think of a better name?

Otherwise

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
