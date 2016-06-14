From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: marvell: fix LED configuration via
 marvell,reg-init
Date: Tue, 14 Jun 2016 15:24:01 -0400 (EDT)
Message-ID: <20160614.152401.2085431617357835569.davem@davemloft.net>
References: <20160611152126.24024-1-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, sposelenov@emcraft.com
To: clemens.gruber@pqgruber.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcFNTYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:24:06 -0400
In-Reply-To: <20160611152126.24024-1-clemens.gruber@pqgruber.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Clemens Gruber <clemens.gruber@pqgruber.com>
Date: Sat, 11 Jun 2016 17:21:26 +0200

> Configuring the PHY LED registers for the Marvell 88E1510 and others is
> not possible, because regardless of the values in marvell,reg-init, it
> is later overridden in m88e1121_config_aneg with a non-standard default.
> 
> This patch moves that default configuration to .config_init to allow
> setting the LED configuration through marvell,reg-init in the device
> tree, which should override said default if it exists.
> 
> Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>

Applied.
