From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Tue, 12 Jul 2016 17:18:09 +0200
Message-ID: <20160712151809.GA31432@lunn.ch>
References: <20160404132552.GH21828@lunn.ch>
 <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40955 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933252AbcGLPSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 11:18:11 -0400
Content-Disposition: inline
In-Reply-To: <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 05:00:52PM +0200, Charles-Antoine Couret wrote:
> Hello,
> I'm back with another patch evrsion about Marvell phys with a fiber interface.
> >From the previous release, I fixed some issues reported by yours and I added some functions around the fiber interface to get statistics, to configure the aneg, etc.

Hi Charles

It is best to submit a number of smaller patches, each doing one
thing, than a single big patch. It makes review and discussion much
simpler.

So for example, this should be a patch of its own:

> @@ -151,6 +165,7 @@ struct marvell_hw_stat {
>  
>  static struct marvell_hw_stat marvell_hw_stats[] = {
>  	{ "phy_receive_errors", 0, 21, 16},
> +	{ "phy_receive_errors_fiber", 1, 21, 16},
>  	{ "phy_idle_errors", 0, 10, 8 },
>  };

I think we should also rename phy_receive_errors to
phy_receive_errors_copper.

	Andrew
