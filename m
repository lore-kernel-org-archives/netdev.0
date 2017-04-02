From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 05/13] ftgmac100: Cleanup speed/duplex tracking and fix
 duplex config
Date: Mon, 03 Apr 2017 07:03:15 +1000
Message-ID: <1491166995.26047.12.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-6-benh@kernel.crashing.org>
         <20170402182848.GA5189@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52048 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750826AbdDBVDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 17:03:25 -0400
In-Reply-To: <20170402182848.GA5189@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 20:28 +0200, Andrew Lunn wrote:
> > +	if (new_speed) {
> > +		netdev_info(netdev, "Link up at %d Mbit/s %s
> > duplex\n",
> > +			    new_speed,
> > +			    phydev->duplex == DUPLEX_FULL ? "full"
> > : "half");
> > +	} else if (priv->cur_speed) {
> > +		/* No link, just return. Leave the HW alone so it
> > can
> > +		 * continue draining the tx ring.
> > +		 */
> > +		netdev_info(netdev, "Link down\n");
> >  		return;
> 
> Hi Ben
> 
> Please consider using phy_print_status().

Thanks. I didn't know about that one. I'll update this.

Cheers,
Ben.
