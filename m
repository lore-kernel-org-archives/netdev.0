From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303
 3-port switch
Date: Thu, 27 Feb 2014 17:02:40 -0500 (EST)
Message-ID: <20140227.170240.1910151216729314077.davem@davemloft.net>
References: <1393492072-15364-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, r.meier@siemens.com,
	lukas.stockmann@siemens.com, f.fainelli@gmail.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaB0WCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:02:43 -0500
In-Reply-To: <1393492072-15364-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Thu, 27 Feb 2014 10:07:52 +0100

> This driver exposes a sysfs interface to access the LAN9303 registers to
> userspace. These sysfs files can be used to configure the switch.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>

We have an abstraction for programming switch devices called DSA.

Even if DSA doesn't fullfill your needs, doing adjustments using sysfs
files in userland is going to be the worst user experience possible.

Every driver will export different things to tweak, each device will
have different semantics and limitations for these settings, etc.

Better is to come up with a real, types, interface for programming
such devices and providing an implementation of that.

I'm not applying this, sorry.
