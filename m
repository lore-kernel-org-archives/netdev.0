From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 00/17] New DSA bind, switches as devices
Date: Sat, 4 Jun 2016 21:28:48 +0200
Message-ID: <20160604192848.GB2063@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Shawn Guo <shawnguo@kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59605 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080AbcFDT2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:28:52 -0400
Content-Disposition: inline
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Andrew Lunn (16):
>   net: dsa: slave: chip data is optional, don't dereference NULL
>   net: dsa: slave: Remove MDIO address from switch MDIO bus name
>   net: dsa: tag_{e}dsa.c: Remove dependency on platform data
>   net: dsa: Add a ports structure and use it in the switch structure
>   net: dsa: Move port device node into port structure
>   net: dsa: Remove dynamic allocate of routing table
>   net: dsa: Copy the routing table into the switch structure
>   net: dsa: Split up creating/destroying of DSA and CPU ports
>   net: dsa: mv88e6xxx: Only support EDSA tagging
>   net: dsa: Refactor selection of tag ops into a function
>   net: dsa: Make mdio bus optional
>   net: dsa: mv88e6xxx: Rename _phy_ to _mdio_
>   net: dsa: mv88e6xxx: Refactor MDIO so driver registers mdio bus
>   net: dsa: Add new binding implementation
>   arm: dt: vf610-zii-devel-b: Make use of new DSA binding

>  arch/arm/boot/dts/vf610-zii-dev-rev-b.dts         | 328 +++++------

Hi Shawn

Are you happy for this VF610 device tree patch to go via netdev, so we
can keep git bisect working.

Thanks
	Andrew
