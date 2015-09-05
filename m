From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Handle postive return codes in phy_connect
Date: Sat, 5 Sep 2015 22:22:57 +0200
Message-ID: <20150905202257.GE6040@lunn.ch>
References: <1441476089-22108-1-git-send-email-mwelling@ieee.org>
 <20150905191840.GC6040@lunn.ch>
 <20150905194400.GA1687@deathstar>
 <20150905194755.GD6040@lunn.ch>
 <20150905202125.GA6250@deathstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Welling <mwelling@ieee.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150905202125.GA6250@deathstar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > It might not be an ERRNO. E.g. https://lkml.org/lkml/2015/9/3/534
> > fixed a bug where a positive value is returned which is not an
> > indication of an error.
> 
> It appears that I have stumbled upon the exact same issue as is fixed in
> the patch above.

Ah, sorry. I put that bug there :-(

The fix should be making its way into the kernel soon.

    Andrew
