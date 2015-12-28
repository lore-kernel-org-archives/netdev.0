From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Mon, 28 Dec 2015 09:58:25 +0100
Message-ID: <20151228085825.GA30297@lunn.ch>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
 <20151228.003243.762236700442924187.davem@davemloft.net>
 <20151228.004427.1444978630699405304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51760 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbbL1I62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2015 03:58:28 -0500
Content-Disposition: inline
In-Reply-To: <20151228.004427.1444978630699405304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2015 at 12:44:27AM -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 28 Dec 2015 00:32:43 -0500 (EST)
> 
> > From: Andrew Lunn <andrew@lunn.ch>
> > Date: Sun, 27 Dec 2015 12:58:25 +0100
> > 
> >> This patchset add ethtool support for reading statistics from the PHY.
> >> The Marvell and Micrel Phys are then extended to report receiver
> >> packet errors and idle errors.
> >> 
> >> v2:
> >>   Fix linking when phylib is not enabled.
> > 
> > Series applied, thanks Andrew.
> 
> I have to revert this.
> 
> You can't call into PHY library code from net/core/ethtool.c,
> because PHY lib can be modular.

O.K.

How about we change PHYLIB from a tristate to a bool?

Thanks
	Andrew
