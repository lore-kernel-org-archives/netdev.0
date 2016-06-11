From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: marvell: fix LED configuration via marvell,reg-init
Date: Sat, 11 Jun 2016 17:47:14 +0200
Message-ID: <20160611154714.GQ2338@lunn.ch>
References: <20160611152126.24024-1-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Sergei Poselenov <sposelenov@emcraft.com>
To: Clemens Gruber <clemens.gruber@pqgruber.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42242 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbcFKPrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jun 2016 11:47:18 -0400
Content-Disposition: inline
In-Reply-To: <20160611152126.24024-1-clemens.gruber@pqgruber.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2016 at 05:21:26PM +0200, Clemens Gruber wrote:
> Configuring the PHY LED registers for the Marvell 88E1510 and others is
> not possible, because regardless of the values in marvell,reg-init, it
> is later overridden in m88e1121_config_aneg with a non-standard default.
> 
> This patch moves that default configuration to .config_init to allow
> setting the LED configuration through marvell,reg-init in the device
> tree, which should override said default if it exists.
> 
> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
