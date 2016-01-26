From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 14:14:35 +0200
Message-ID: <20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
 <20160126044624.GH3880@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:57095 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932935AbcAZMOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 07:14:40 -0500
Content-Disposition: inline
In-Reply-To: <20160126044624.GH3880@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jan 26, 2016 at 05:46:24AM +0100, Andrew Lunn wrote:
> On Mon, Jan 25, 2016 at 05:45:21PM +0200, Aaro Koskinen wrote:
> > I get the below crash on OCTEON (with octeon_mgmt interface, genphy)
> > always during systemd boot.
> 
> I think i know what is going on now.
> 
> What does your phy look like in DT?

It's using the in-kernel DT:

	arch/mips/boot/dts/cavium-octeon/octeon_3xxx.dts

The management interface is "mix0: ethernet@1070000100000". The phy entry
might be bogus for this specific board, and I don't have MARVELL_PHY
enabled...

A.
