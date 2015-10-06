From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH] net: mvneta: add ethtool statistics
Date: Tue, 6 Oct 2015 18:52:08 +0200
Message-ID: <20151006165208.GE3557@lunn.ch>
References: <E1Zimcg-0008HA-0y@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36742 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbbJFQwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 12:52:10 -0400
Content-Disposition: inline
In-Reply-To: <E1Zimcg-0008HA-0y@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 04, 2015 at 05:58:54PM +0100, Russell King wrote:
> Add support for the ethtool statistic interface, returning the full set
> of statistics which both the Armada 370 and Armada XP can support.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
> Is there any standard terminology for the ethtool statistics?  Are the
> names given here satisfactory?

Hi Russell

Maybe you can use the same as drivers/net/dsa/mv88e6xxx.c? Or the same
as net/ethernet/marvell/mv643xx_eth.c

At least in the Marvell drivers, there does not seem to be any
consistency. But we should try to avoid adding a third set for
Marvell, if there is no standard.

	 Andrew
