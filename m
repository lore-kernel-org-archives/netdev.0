From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 00/22] Support MDIO devices
Date: Thu, 7 Jan 2016 21:14:34 +0100
Message-ID: <20160107201434.GD1356@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
 <20160107.143357.139530014387548318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43453 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733AbcAGUOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 15:14:36 -0500
Content-Disposition: inline
In-Reply-To: <20160107.143357.139530014387548318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 02:33:57PM -0500, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed,  6 Jan 2016 20:11:05 +0100
> 
> > The discussions about changing the way DSA probes switches resulted in
> > the wish to have switches attached to an MDIO bus to be represented as
> > an MDIO device. However the current code only supports PHYs on MDIO
> > busses. This patchset remedies this problem. It consists of a number
> > of cleanups, abstraction for accessing structure members, and
> > refactoring, as well as adding the concept of a generic MDIO device
> > and MDIO driver.
> > 
> > v2:
> > Added Reviewed-by from Florian
> > Made phydev_name() an inline function
> > Added phy_attached_info/phy_attached_print() for information about
> > the attached phy.
> > Removed now redundant irq setup from of_mdio.c
> > Dropped hunks from PHYMII ioctl which prevented access to any address
> > DSA carrier off before phy setup
> 
> Series applied, thanks Andrew.

Hi Dave

You might get some build failures from less well used
architectures/drivers.  I've got a couple of 0-day emails i need to
send fixups for.

     Andrew
