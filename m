From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: macb: Probe MDIO bus before registering netdev
Date: Tue, 03 May 2016 16:06:39 -0400 (EDT)
Message-ID: <20160503.160639.1068257904610872494.davem@davemloft.net>
References: <1462239525-22723-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032AbcECUGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:06:41 -0400
In-Reply-To: <1462239525-22723-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  2 May 2016 18:38:45 -0700

> The current sequence makes us register for a network device prior to
> registering and probing the MDIO bus which could lead to some unwanted
> consequences, like a thread of execution calling into ndo_open before
> register_netdev() returns, while the MDIO bus is not ready yet.
> 
> Rework the sequence to register for the MDIO bus, and therefore attach
> to a PHY prior to calling register_netdev(), which implies reworking the
> error path a bit.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
