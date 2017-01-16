From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: don't use netdev_[dbg, info, ..] before
 net_device is registered
Date: Mon, 16 Jan 2017 14:52:40 -0500 (EST)
Message-ID: <20170116.145240.496347319342609740.davem@davemloft.net>
References: <01b736a6-b9e9-05cf-0937-f6ac18ac8e3c@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkallweit1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdAPUCE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:02:04 -0500
In-Reply-To: <01b736a6-b9e9-05cf-0937-f6ac18ac8e3c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <hkallweit1@gmail.com>
Date: Sun, 15 Jan 2017 19:19:00 +0100

> Don't use netdev_info and friends before the net_device is registered.
> This avoids ugly messages like
> "meson8b-dwmac c9410000.ethernet (unnamed net_device) (uninitialized):
> Enable RX Mitigation via HW Watchdog Timer"
> 
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>

Indeed, this is a side-effect of the MDIO vs. register_netdev race fix
that went in the other week.

Applied, thanks.
