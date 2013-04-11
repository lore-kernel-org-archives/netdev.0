From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Thu, 11 Apr 2013 12:53:03 -0400
Message-ID: <20130411165303.GI28693@titan.lakedaemon.net>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	moinejf@free.fr, andrew@lunn.ch, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
	grant.likely@secretlab.ca, jogo@openwrt.org,
	buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:35818 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935114Ab3DKQxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 12:53:22 -0400
Content-Disposition: inline
In-Reply-To: <1365071235-11611-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian,

On Thu, Apr 04, 2013 at 12:27:10PM +0200, Florian Fainelli wrote:
> Hi all,
> 
> This patch serie implements mv643xx_eth device tree bindings. I opted for
> the reuse of the bindings already defined in
> Documentation/devicetree/bindings/marvell.txt so that we do not create
> any confusion.
> 
> For reference, I have included the mv643xx-eth related nodes in the
> corresponding Kirkwood, Dove and Orion5x .dtsi files so you can more
> easily test on your own platforms.
> 
> I tested these on a custom 88F6181-based boards.
> 
> Florian Fainelli (5):
>   mv643xx_eth: add Device Tree bindings
>   mv643xx_eth: update Device Tree bindings documentation
>   ARM: kirkwood: add device node entries for the gigabit interfaces
>   ARM: orion5x: add gigabit ethernet device tree node
>   ARM: dove: add gigabit device tree nodes to dove.dtsi
> 
>  Documentation/devicetree/bindings/marvell.txt |   25 +++++-
>  arch/arm/boot/dts/dove.dtsi                   |   25 ++++++
>  arch/arm/boot/dts/kirkwood.dtsi               |   46 ++++++++++
>  arch/arm/boot/dts/orion5x.dtsi                |   23 +++++
>  drivers/net/ethernet/marvell/mv643xx_eth.c    |  120 ++++++++++++++++++++++++-
>  5 files changed, 234 insertions(+), 5 deletions(-)

How is the new version of this looking?  Do you think you'll be able to
get it up in time for DaveM to take it into v3.10?

With this and Thomas' pci series, we will have Kirkwood fully converted
to devicetree, can begin removing board files, and finally begin
migrating everything over to mach-mvebu/.  This will lead to the removal
of five directories under arch/arm/ (plat-orion, mach-kirkwood,
mach-orion5x, mach-dove, and mach-mv78xx0).

thx,

Jason.
