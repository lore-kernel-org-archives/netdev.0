From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/5] net: dsa: b53: Add support for Broadcom
 RoboSwitch
Date: Fri, 10 Jun 2016 20:57:20 +0200
Message-ID: <20160610185720.GH2338@lunn.ch>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
 <1465521837-30193-2-git-send-email-f.fainelli@gmail.com>
 <20160610121149.GC2338@lunn.ch>
 <575B0BA4.9010708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	davem@davemloft.net, jon.mason@broadcom.com,
	hemal.shah@broadcom.com, bandaru.viswanath@broadcom.com,
	michael.chan@broadcom.com, jogo@openwrt.org, cphealy@gmail.com,
	ardeleanalex@gmail.com, jiri@mellanox.com, idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41800 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbcFJS5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 14:57:23 -0400
Content-Disposition: inline
In-Reply-To: <575B0BA4.9010708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> +static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
> >> +{
> >> +	enum bcm47xx_board board = bcm47xx_board_get();
> >> +
> >> +	switch (board) {
> >> +	case BCM47XX_BOARD_LINKSYS_WRT300NV11:
> >> +	case BCM47XX_BOARD_LINKSYS_WRT310NV1:
> >> +		return 8;
> > 
> > Rather than hard coding it, could we get it from device tree?
> 
> Difficult for now, this is for in-tree MIPS-based platforms under
> arch/mips/bcm47xx, which are using SSB/platform data.

Ah, O.K.

But it would not harm to also support getting the GPIO from device
tree, if device tree is available. But maybe that should wait until
such a user comes along.

     Andrew
