From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: force link for all fixed PHY
 devices
Date: Thu, 11 Dec 2014 21:17:30 -0500 (EST)
Message-ID: <20141211.211730.1580416739560489011.davem@davemloft.net>
References: <1418350362-29183-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbaLLCRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 21:17:32 -0500
In-Reply-To: <1418350362-29183-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 11 Dec 2014 18:12:42 -0800

> For ports of the switch that we define as "fixed PHYs" such as MoCA, we
> would have our Port 7 special handling that would allow us to assert the
> link status indication.
> 
> For other ports, such as e.g: RGMII_1 connected to a cable modem, we
> would rely on whatever the bootloader has left configured, which is a
> bad assumption to make, we really need to force the link status
> indication here.
> 
> Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
